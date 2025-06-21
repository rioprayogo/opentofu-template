# Local values
locals {
  name_prefix = "${var.project_name}-${var.environment}"
  vm_config_map = { for idx, vm in var.vm_config : idx => vm }
  
  # Determine if we're using existing VPC (all VMs must use same VPC strategy)
  use_existing_vpc = length(var.vm_config) > 0 ? var.vm_config[0].network.use_existing_vpc : false
  
  # Get VPC name from first VM config
  vpc_name = local.use_existing_vpc ? var.vm_config[0].network.existing_vpc.vpc_name : var.vm_config[0].network.new_vpc.vpc_name
}

# Resource Group
resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

# Data source untuk existing VPC
data "azurerm_virtual_network" "existing" {
  count               = local.use_existing_vpc ? 1 : 0
  name                = var.vm_config[0].network.existing_vpc.vpc_name
  resource_group_name = azurerm_resource_group.main.name
  
  lifecycle {
    postcondition {
      condition     = self.id != null
      error_message = "Existing VPC '${var.vm_config[0].network.existing_vpc.vpc_name}' not found in resource group '${azurerm_resource_group.main.name}'."
    }
  }
}

# Data source untuk existing NSG
data "azurerm_network_security_group" "existing" {
  count               = local.use_existing_vpc ? 1 : 0
  name                = var.vm_config[0].network.existing_vpc.existing_nsg_name
  resource_group_name = azurerm_resource_group.main.name
  
  lifecycle {
    postcondition {
      condition     = self.id != null
      error_message = "Existing NSG '${var.vm_config[0].network.existing_vpc.existing_nsg_name}' not found in resource group '${azurerm_resource_group.main.name}'."
    }
  }
}

# Virtual Network (hanya jika use_existing_vpc = false)
resource "azurerm_virtual_network" "main" {
  count               = local.use_existing_vpc ? 0 : 1
  name                = var.vm_config[0].network.new_vpc.vpc_name
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  address_space       = [var.vnet_cidr]
  tags                = var.tags
}

# Network Security Group (hanya jika use_existing_vpc = false)
resource "azurerm_network_security_group" "main" {
  count               = local.use_existing_vpc ? 0 : 1
  name                = "${local.name_prefix}-nsg"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  tags                = var.tags

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "HTTP"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "HTTPS"
    priority                   = 1003
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Subnets untuk setiap VM
resource "azurerm_subnet" "vm_subnets" {
  count                = length(var.vm_config)
  name                 = "subnet-${var.vm_config[count.index].instance_name}"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = local.use_existing_vpc ? data.azurerm_virtual_network.existing[0].name : azurerm_virtual_network.main[0].name
  address_prefixes     = [local.use_existing_vpc ? var.vm_config[count.index].network.existing_vpc.subnet_cidr : var.vm_config[count.index].network.new_vpc.subnet_cidr]
}

# Public IP Addresses (hanya untuk VM yang enable_public_ip = true)
resource "azurerm_public_ip" "vm_ips" {
  count               = length([for vm in var.vm_config : vm if vm.enable_public_ip])
  name                = "${local.name_prefix}-pip-${count.index + 1}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  allocation_method   = "Dynamic"
  tags                = var.tags
}

# Network Interfaces
resource "azurerm_network_interface" "vm_nics" {
  count               = length(var.vm_config)
  name                = "nic-${var.vm_config[count.index].instance_name}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  
  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.vm_subnets[count.index].id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = var.vm_config[count.index].enable_public_ip ? azurerm_public_ip.vm_ips[index([for vm in var.vm_config : vm if vm.enable_public_ip], var.vm_config[count.index])].id : null
  }
  
  tags = var.tags
}

# Network Interface Security Group Association
resource "azurerm_network_interface_security_group_association" "nsg_association" {
  count                     = length(var.vm_config)
  network_interface_id      = azurerm_network_interface.vm_nics[count.index].id
  network_security_group_id = local.use_existing_vpc ? data.azurerm_network_security_group.existing[0].id : azurerm_network_security_group.main[0].id
}

# Virtual Machines
resource "azurerm_linux_virtual_machine" "vms" {
  count               = length(var.vm_config)
  name                = var.vm_config[count.index].instance_name
  resource_group_name = azurerm_resource_group.main.name
  location            = var.vm_config[count.index].location
  size                = var.vm_config[count.index].instance_type
  admin_username      = "adminuser"
  network_interface_ids = [azurerm_network_interface.vm_nics[count.index].id]

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    disk_size_gb         = var.vm_config[count.index].os_disk_size_gb
  }

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  tags = merge(var.tags, {
    VMIndex = count.index
    InstanceName = var.vm_config[count.index].instance_name
  })
}

# Additional Data Disks
resource "azurerm_managed_disk" "vm_data_disks" {
  count                = sum([for vm in var.vm_config : length(vm.additional_disks)])
  name                 = "disk-${var.vm_config[floor(count.index / max(length(var.vm_config[0].additional_disks), 1))].instance_name}-${count.index % max(length(var.vm_config[0].additional_disks), 1) + 1}"
  location             = azurerm_resource_group.main.location
  resource_group_name  = azurerm_resource_group.main.name
  storage_account_type = var.vm_config[floor(count.index / max(length(var.vm_config[0].additional_disks), 1))].additional_disks[count.index % max(length(var.vm_config[0].additional_disks), 1)].storage_type
  create_option        = "Empty"
  disk_size_gb         = var.vm_config[floor(count.index / max(length(var.vm_config[0].additional_disks), 1))].additional_disks[count.index % max(length(var.vm_config[0].additional_disks), 1)].size_gb
  tags                 = var.tags
}

# Data Disk Attachments
resource "azurerm_virtual_machine_data_disk_attachment" "vm_data_disks" {
  count              = sum([for vm in var.vm_config : length(vm.additional_disks)])
  managed_disk_id    = azurerm_managed_disk.vm_data_disks[count.index].id
  virtual_machine_id = azurerm_linux_virtual_machine.vms[floor(count.index / max(length(var.vm_config[0].additional_disks), 1))].id
  lun                = count.index % max(length(var.vm_config[0].additional_disks), 1)
  caching            = var.vm_config[floor(count.index / max(length(var.vm_config[0].additional_disks), 1))].additional_disks[count.index % max(length(var.vm_config[0].additional_disks), 1)].caching
}

# Monitoring (Optional)
resource "azurerm_monitor_diagnostic_setting" "vm_diagnostics" {
  count                      = var.enable_monitoring ? length(var.vm_config) : 0
  name                       = "${local.name_prefix}-diag-${count.index + 1}"
  target_resource_id         = azurerm_linux_virtual_machine.vms[count.index].id
  storage_account_id         = azurerm_storage_account.diagnostics[0].id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.main[0].id

  log {
    category = "Syslog"
    enabled  = true

    retention_policy {
      enabled = true
      days    = 30
    }
  }

  metric {
    category = "AllMetrics"
    enabled  = true

    retention_policy {
      enabled = true
      days    = 30
    }
  }
}

# Storage Account for Diagnostics
resource "azurerm_storage_account" "diagnostics" {
  count                    = var.enable_monitoring ? 1 : 0
  name                     = substr(replace("${local.name_prefix}diag${random_string.storage[0].result}", "-", ""), 0, 24)
  resource_group_name      = azurerm_resource_group.main.name
  location                 = azurerm_resource_group.main.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  tags                     = var.tags
}

# Log Analytics Workspace
resource "azurerm_log_analytics_workspace" "main" {
  count               = var.enable_monitoring ? 1 : 0
  name                = "${local.name_prefix}-law"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
  tags                = var.tags
}

# Random string for storage account name
resource "random_string" "storage" {
  count   = var.enable_monitoring ? 1 : 0
  length  = 8
  special = false
  upper   = false
} 