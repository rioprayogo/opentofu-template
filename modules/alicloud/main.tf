terraform {
  required_providers {
    alicloud = {
      source  = "aliyun/alicloud"
      version = "~> 1.0"
    }
  }
}

# Data source for available zones
data "alicloud_zones" "available" {
  available_instance_type = var.vm_config[0].instance_type
}

# Data source for Ubuntu image
data "alicloud_images" "ubuntu" {
  name_regex = "^ubuntu_20_04"
  owners     = "system"
}

# Local values for VPC configuration
locals {
  use_existing_vpc = var.vm_config[0].network.use_existing_vpc
  vpc_name = local.use_existing_vpc ? var.vm_config[0].network.existing_vpc.vpc_name : var.vm_config[0].network.new_vpc.vpc_name
  name_prefix = "${var.project_name}-${var.environment}"
}

# Data source for existing VPC
data "alicloud_vpcs" "existing" {
  count = local.use_existing_vpc ? 1 : 0
  name_regex = local.vpc_name
}

# Data source for existing VSwitch
data "alicloud_vswitches" "existing" {
  count = local.use_existing_vpc ? 1 : 0
  vpc_id = data.alicloud_vpcs.existing[0].vpcs.0.id
}

# Data source for existing Security Group
data "alicloud_security_groups" "existing" {
  count = local.use_existing_vpc ? 1 : 0
  vpc_id = data.alicloud_vpcs.existing[0].vpcs.0.id
  name_regex = var.vm_config[0].network.existing_vpc.existing_nsg_name
}

# VPC
resource "alicloud_vpc" "main" {
  count = local.use_existing_vpc ? 0 : 1
  vpc_name   = "${var.project_name}-vpc"
  cidr_block = var.vpc_cidr
  tags = var.tags
}

# VSwitches (Subnets)
resource "alicloud_vswitch" "subnets" {
  count = local.use_existing_vpc ? 0 : length(var.vm_config)
  
  vpc_id     = alicloud_vpc.main[0].id
  cidr_block = var.vm_config[count.index].network.new_vpc.subnet_cidr
  zone_id    = data.alicloud_zones.available.zones[count.index % length(data.alicloud_zones.available.zones)].id
  vswitch_name = "${var.vm_config[count.index].instance_name}-subnet"
  tags = var.tags
}

# Security Group
resource "alicloud_security_group" "main" {
  count = local.use_existing_vpc ? 0 : 1
  name   = "${var.project_name}-nsg"
  vpc_id = alicloud_vpc.main[0].id
  tags = var.tags
}

# Security Group Rules
resource "alicloud_security_group_rule" "ssh" {
  count = local.use_existing_vpc ? 0 : 1
  type              = "ingress"
  ip_protocol       = "tcp"
  nic_type          = "intranet"
  policy            = "accept"
  port_range        = "22/22"
  priority          = 1
  security_group_id = alicloud_security_group.main[0].id
  cidr_ip           = "0.0.0.0/0"
}

resource "alicloud_security_group_rule" "http" {
  count = local.use_existing_vpc ? 0 : 1
  type              = "ingress"
  ip_protocol       = "tcp"
  nic_type          = "intranet"
  policy            = "accept"
  port_range        = "80/80"
  priority          = 1
  security_group_id = alicloud_security_group.main[0].id
  cidr_ip           = "0.0.0.0/0"
}

resource "alicloud_security_group_rule" "https" {
  count = local.use_existing_vpc ? 0 : 1
  type              = "ingress"
  ip_protocol       = "tcp"
  nic_type          = "intranet"
  policy            = "accept"
  port_range        = "443/443"
  priority          = 1
  security_group_id = alicloud_security_group.main[0].id
  cidr_ip           = "0.0.0.0/0"
}

# ECS Instances
resource "alicloud_instance" "vms" {
  count = length(var.vm_config)
  
  instance_name = var.vm_config[count.index].instance_name
  instance_type = var.vm_config[count.index].instance_type
  image_id      = data.alicloud_images.ubuntu.images[0].id
  vswitch_id    = local.use_existing_vpc ? data.alicloud_vswitches.existing[0].vswitches[count.index % length(data.alicloud_vswitches.existing[0].vswitches)].id : alicloud_vswitch.subnets[count.index].id
  security_groups = local.use_existing_vpc ? [data.alicloud_security_groups.existing[0].groups.0.id] : [alicloud_security_group.main[0].id]
  
  system_disk_category = "cloud_efficiency"
  system_disk_size     = var.vm_config[count.index].os_disk_size_gb
  
  internet_charge_type = "PayByTraffic"
  internet_max_bandwidth_out = 10
  
  password = "TempPassword123!" # This should be from variables
  
  tags = merge(var.tags, {
    Name = var.vm_config[count.index].instance_name
  })
}

# Data Disks
resource "alicloud_disk" "data_disks" {
  count = sum([
    for vm_index, vm_config in var.vm_config : length(vm_config.additional_disks)
  ])
  
  name   = "disk-${count.index}"
  size   = var.vm_config[local.disk_to_vm_map[count.index].vm_index].additional_disks[local.disk_to_vm_map[count.index].disk_index].size_gb
  category = "cloud_efficiency"
  zone_id     = data.alicloud_zones.available.zones[local.disk_to_vm_map[count.index].vm_index % length(data.alicloud_zones.available.zones)].id
  
  tags = merge(var.tags, {
    Name = "disk-${count.index}"
  })
}

# Attach Data Disks to VMs
resource "alicloud_disk_attachment" "data_disks" {
  count = sum([
    for vm_index, vm_config in var.vm_config : length(vm_config.additional_disks)
  ])
  
  disk_id     = alicloud_disk.data_disks[count.index].id
  instance_id = alicloud_instance.vms[local.disk_to_vm_map[count.index].vm_index].id
}

# Local values for disk mapping
locals {
  disk_to_vm_map = flatten([
    for vm_index, vm_config in var.vm_config : [
      for disk_index, disk in vm_config.additional_disks : {
        vm_index   = vm_index
        disk_index = disk_index
      }
    ]
  ])
}

# Cloud Monitor (if monitoring enabled)
resource "alicloud_cms_alarm" "cpu" {
  count   = var.enable_monitoring ? length(var.vm_config) : 0
  name    = "${local.name_prefix}-cpu-alarm-${count.index + 1}"
  project = "acs_ecs_dashboard"
  metric  = "cpu_total"
  metric_dimensions = "[{\"instanceId\":\"${alicloud_instance.vms[count.index].id}\"}]"
  period  = 300
  contact_groups = ["default"]
  escalations_critical {
    statistics = "Average"
    comparison_operator = ">="
    threshold = "80"
    times = "2"
  }
} 