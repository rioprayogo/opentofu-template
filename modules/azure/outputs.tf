output "resource_group_name" {
  description = "Name of the resource group"
  value       = azurerm_resource_group.main.name
}

output "resource_group_location" {
  description = "Location of the resource group"
  value       = azurerm_resource_group.main.location
}

output "vnet_name" {
  description = "Name of the virtual network"
  value       = var.vm_config[0].network.use_existing_vpc ? data.azurerm_virtual_network.existing[0].name : azurerm_virtual_network.main[0].name
}

output "vnet_id" {
  description = "ID of the virtual network"
  value       = var.vm_config[0].network.use_existing_vpc ? data.azurerm_virtual_network.existing[0].id : azurerm_virtual_network.main[0].id
}

output "subnet_ids" {
  description = "IDs of the subnets"
  value       = azurerm_subnet.vm_subnets[*].id
}

output "subnet_names" {
  description = "Names of the subnets"
  value       = azurerm_subnet.vm_subnets[*].name
}

output "nsg_id" {
  description = "ID of the network security group"
  value       = var.vm_config[0].network.use_existing_vpc ? data.azurerm_network_security_group.existing[0].id : azurerm_network_security_group.main[0].id
}

output "vm_names" {
  description = "Names of the virtual machines"
  value       = azurerm_linux_virtual_machine.vms[*].name
}

output "vm_ids" {
  description = "IDs of the virtual machines"
  value       = azurerm_linux_virtual_machine.vms[*].id
}

output "public_ips" {
  description = "Public IP addresses of the virtual machines"
  value       = azurerm_public_ip.vm_ips[*].ip_address
}

output "private_ips" {
  description = "Private IP addresses of the virtual machines"
  value       = azurerm_network_interface.vm_nics[*].private_ip_address
}

output "ssh_command" {
  description = "SSH command to connect to the first VM"
  value       = "ssh adminuser@${azurerm_public_ip.vm_ips[0].ip_address}"
}

output "monitoring_enabled" {
  description = "Whether monitoring is enabled"
  value       = var.enable_monitoring
}

output "log_analytics_workspace_id" {
  description = "ID of the Log Analytics workspace"
  value       = var.enable_monitoring ? azurerm_log_analytics_workspace.main[0].id : null
} 