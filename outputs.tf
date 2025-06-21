# Azure Outputs
output "azure_resource_group_name" {
  description = "Azure resource group name"
  value       = var.cloud_provider == "azure" ? module.azure_infrastructure[0].resource_group_name : null
}

output "azure_vnet_name" {
  description = "Azure virtual network name"
  value       = var.cloud_provider == "azure" ? module.azure_infrastructure[0].vnet_name : null
}

output "azure_vm_public_ips" {
  description = "Azure VM public IP addresses"
  value       = var.cloud_provider == "azure" ? module.azure_infrastructure[0].vm_public_ips : null
}

# AWS Outputs
output "aws_vpc_id" {
  description = "AWS VPC ID"
  value       = var.cloud_provider == "aws" ? module.aws_infrastructure[0].vpc_id : null
}

output "aws_instance_public_ips" {
  description = "AWS instance public IP addresses"
  value       = var.cloud_provider == "aws" ? module.aws_infrastructure[0].instance_public_ips : null
}

# GCP Outputs
output "gcp_network_name" {
  description = "GCP network name"
  value       = var.cloud_provider == "gcp" ? module.gcp_infrastructure[0].network_name : null
}

output "gcp_instance_public_ips" {
  description = "GCP instance public IP addresses"
  value       = var.cloud_provider == "gcp" ? module.gcp_infrastructure[0].instance_public_ips : null
}

# Alibaba Cloud Outputs
output "alicloud_vpc_id" {
  description = "Alibaba Cloud VPC ID"
  value       = var.cloud_provider == "alicloud" ? module.alicloud_infrastructure[0].vpc_id : null
}

output "alicloud_instance_public_ips" {
  description = "Alibaba Cloud instance public IP addresses"
  value       = var.cloud_provider == "alicloud" ? module.alicloud_infrastructure[0].instance_public_ips : null
}

# Common Outputs
output "cloud_provider" {
  description = "Selected cloud provider"
  value       = var.cloud_provider
}

output "environment" {
  description = "Environment name"
  value       = var.environment
}

output "project_name" {
  description = "Project name"
  value       = var.project_name
}

output "location" {
  description = "Primary location/region"
  value       = var.location
}
