output "vpc_id" {
  description = "ID of the VPC"
  value       = var.vm_config[0].network.use_existing_vpc ? data.alicloud_vpcs.existing[0].vpcs.0.id : alicloud_vpc.main[0].id
}

output "vpc_name" {
  description = "Name of the VPC"
  value       = var.vm_config[0].network.use_existing_vpc ? data.alicloud_vpcs.existing[0].vpcs.0.vpc_name : alicloud_vpc.main[0].vpc_name
}

output "vswitch_ids" {
  description = "IDs of the VSwitches"
  value       = var.vm_config[0].network.use_existing_vpc ? data.alicloud_vswitches.existing[0].vswitches[*].id : alicloud_vswitch.subnets[*].id
}

output "vswitch_names" {
  description = "Names of the VSwitches"
  value       = var.vm_config[0].network.use_existing_vpc ? data.alicloud_vswitches.existing[0].vswitches[*].vswitch_name : alicloud_vswitch.subnets[*].vswitch_name
}

output "security_group_id" {
  description = "ID of the security group"
  value       = var.vm_config[0].network.use_existing_vpc ? data.alicloud_security_groups.existing[0].groups.0.id : alicloud_security_group.main[0].id
}

output "security_group_name" {
  description = "Name of the security group"
  value       = var.vm_config[0].network.use_existing_vpc ? data.alicloud_security_groups.existing[0].groups.0.name : alicloud_security_group.main[0].name
}

output "instance_ids" {
  description = "IDs of the ECS instances"
  value       = alicloud_instance.vms[*].id
}

output "instance_names" {
  description = "Names of the ECS instances"
  value       = alicloud_instance.vms[*].instance_name
}

output "public_ips" {
  description = "Public IP addresses of the ECS instances"
  value       = alicloud_instance.vms[*].public_ip
}

output "private_ips" {
  description = "Private IP addresses of the ECS instances"
  value       = alicloud_instance.vms[*].private_ip
}

output "ssh_command" {
  description = "SSH command to connect to the first instance"
  value       = "ssh root@${alicloud_instance.vms[0].public_ip}"
}

output "monitoring_enabled" {
  description = "Whether monitoring is enabled"
  value       = var.enable_monitoring
}

output "alarm_names" {
  description = "Names of the Cloud Monitor alarms"
  value       = alicloud_cms_alarm.cpu[*].name
} 