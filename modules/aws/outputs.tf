output "vpc_id" {
  description = "ID of the VPC"
  value       = var.vm_config[0].network.use_existing_vpc ? data.aws_vpc.existing[0].id : aws_vpc.main[0].id
}

output "vpc_cidr_block" {
  description = "CIDR block of the VPC"
  value       = var.vm_config[0].network.use_existing_vpc ? data.aws_vpc.existing[0].cidr_block : aws_vpc.main[0].cidr_block
}

output "subnet_ids" {
  description = "IDs of the subnets"
  value       = aws_subnet.vm_subnets[*].id
}

output "subnet_cidr_blocks" {
  description = "CIDR blocks of the subnets"
  value       = aws_subnet.vm_subnets[*].cidr_block
}

output "security_group_id" {
  description = "ID of the security group"
  value       = aws_security_group.main.id
}

output "instance_ids" {
  description = "IDs of the EC2 instances"
  value       = aws_instance.main[*].id
}

output "instance_names" {
  description = "Names of the EC2 instances"
  value       = aws_instance.main[*].tags.Name
}

output "public_ips" {
  description = "Public IP addresses of the EC2 instances"
  value       = aws_instance.main[*].public_ip
}

output "private_ips" {
  description = "Private IP addresses of the EC2 instances"
  value       = aws_instance.main[*].private_ip
}

output "ssh_command" {
  description = "SSH command to connect to the first instance"
  value       = "ssh ubuntu@${aws_instance.main[0].public_ip}"
}

output "monitoring_enabled" {
  description = "Whether monitoring is enabled"
  value       = var.enable_monitoring
}

output "cloudwatch_log_group_name" {
  description = "Name of the CloudWatch log group"
  value       = var.enable_monitoring ? aws_cloudwatch_log_group.main[0].name : null
} 