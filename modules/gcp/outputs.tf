output "network_name" {
  description = "Name of the VPC network"
  value       = google_compute_network.main.name
}

output "network_id" {
  description = "ID of the VPC network"
  value       = google_compute_network.main.id
}

output "subnet_names" {
  description = "Names of the subnets"
  value       = google_compute_subnetwork.subnets[*].name
}

output "subnet_ids" {
  description = "IDs of the subnets"
  value       = google_compute_subnetwork.subnets[*].id
}

output "firewall_name" {
  description = "Name of the firewall rule"
  value       = google_compute_firewall.main.name
}

output "instance_names" {
  description = "Names of the compute instances"
  value       = google_compute_instance.instances[*].name
}

output "instance_ids" {
  description = "IDs of the compute instances"
  value       = google_compute_instance.instances[*].id
}

output "instance_public_ips" {
  description = "Public IP addresses of the compute instances"
  value       = google_compute_instance.instances[*].network_interface[0].access_config[0].nat_ip
}

output "instance_private_ips" {
  description = "Private IP addresses of the compute instances"
  value       = google_compute_instance.instances[*].network_interface[0].network_ip
}

output "ssh_command" {
  description = "SSH command to connect to the first instance"
  value       = "ssh debian@${google_compute_instance.instances[0].network_interface[0].access_config[0].nat_ip}"
}

output "monitoring_enabled" {
  description = "Whether monitoring is enabled"
  value       = var.enable_monitoring
}

output "log_bucket_name" {
  description = "Name of the log storage bucket"
  value       = var.enable_monitoring ? google_storage_bucket.logs[0].name : null
} 