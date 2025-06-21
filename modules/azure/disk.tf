# Flexible Disk Management for Azure VMs
# Supports different disk configurations per VM

# Data Disk tambahan untuk VM (LEGACY - backward compatibility)
resource "azurerm_managed_disk" "data_disks_legacy" {
  count                = var.additional_disks_count > 0 ? var.instance_count * var.additional_disks_count : 0
  name                 = "${local.name_prefix}-data-disk-legacy-${floor(count.index / var.additional_disks_count) + 1}-${(count.index % var.additional_disks_count) + 1}"
  location             = azurerm_resource_group.main.location
  resource_group_name  = azurerm_resource_group.main.name
  storage_account_type = var.data_disk_storage_type
  create_option        = "Empty"
  disk_size_gb         = var.data_disk_size_gb

  tags = var.tags
}

# Attachment Data Disk ke VM (LEGACY)
resource "azurerm_virtual_machine_data_disk_attachment" "data_disks_legacy" {
  count              = var.additional_disks_count > 0 ? var.instance_count * var.additional_disks_count : 0
  managed_disk_id    = azurerm_managed_disk.data_disks_legacy[count.index].id
  virtual_machine_id = azurerm_linux_virtual_machine.vms[floor(count.index / var.additional_disks_count)].id
  lun                = (count.index % var.additional_disks_count) + 10
  caching            = "ReadWrite"
}

# NEW: Flexible Data Disks per VM - Simplified syntax
locals {
  flexible_disks = flatten([
    for idx, vm in var.vm_config : [
      for disk_index, disk in vm.additional_disks : {
        vm_index     = idx
        instance_name = vm.instance_name
        disk_index   = disk_index
        size_gb      = disk.size_gb
        storage_type = disk.storage_type
        caching      = disk.caching
        key          = "${idx}-${disk_index}"
      }
    ]
  ])
  flexible_disks_map = { for disk in local.flexible_disks : disk.key => disk }
}

resource "azurerm_managed_disk" "data_disks_flexible" {
  for_each = local.flexible_disks_map
  name                 = "${local.name_prefix}-data-disk-${each.value.instance_name}-${each.value.disk_index + 1}"
  location             = azurerm_resource_group.main.location
  resource_group_name  = azurerm_resource_group.main.name
  storage_account_type = each.value.storage_type
  create_option        = "Empty"
  disk_size_gb         = each.value.size_gb
  tags = merge(var.tags, {
    VMIndex   = each.value.vm_index
    InstanceName = each.value.instance_name
    DiskIndex = each.value.disk_index
  })
}

# Attachment Flexible Data Disks ke VM
resource "azurerm_virtual_machine_data_disk_attachment" "data_disks_flexible" {
  for_each = local.flexible_disks_map
  managed_disk_id    = azurerm_managed_disk.data_disks_flexible[each.key].id
  virtual_machine_id = azurerm_linux_virtual_machine.vms[each.value.vm_index].id
  lun                = each.value.disk_index + 10
  caching            = each.value.caching
}

# Output untuk disk information
output "data_disk_ids_legacy" {
  description = "IDs of the legacy data disks"
  value       = azurerm_managed_disk.data_disks_legacy[*].id
}

output "data_disk_ids_flexible" {
  description = "IDs of the flexible data disks"
  value       = values(azurerm_managed_disk.data_disks_flexible)[*].id
}

output "total_disk_count" {
  description = "Total number of disks (VM + Data disks)"
  value       = var.instance_count + length(azurerm_managed_disk.data_disks_legacy) + length(azurerm_managed_disk.data_disks_flexible)
}

output "vm_disk_configurations" {
  description = "Disk configurations for each VM"
  value = {
    for idx, vm in var.vm_config : vm.instance_name => {
      os_disk_size_gb = vm.os_disk_size_gb
      additional_disks_count = length(vm.additional_disks)
      total_disks = length(vm.additional_disks) + 1
    }
  }
} 