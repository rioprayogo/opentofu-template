# Local values
locals {
  name_prefix = "${var.project_name}-${var.environment}"
  use_existing_vpc = length(var.vm_config) > 0 ? var.vm_config[0].network.use_existing_vpc : false
  vpc_name = local.use_existing_vpc ? var.vm_config[0].network.existing_vpc.vpc_name : var.vm_config[0].network.new_vpc.vpc_name
}

# Data source for existing VPC
data "aws_vpc" "existing" {
  count = local.use_existing_vpc ? 1 : 0
  filter {
    name   = "tag:Name"
    values = [local.vpc_name]
  }
}

# VPC (only if use_existing_vpc = false)
resource "aws_vpc" "main" {
  count                = local.use_existing_vpc ? 0 : 1
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = merge(var.tags, {
    Name = local.vpc_name
  })
}

# Internet Gateway (only if use_existing_vpc = false)
resource "aws_internet_gateway" "main" {
  count  = local.use_existing_vpc ? 0 : 1
  vpc_id = aws_vpc.main[0].id
  tags = merge(var.tags, {
    Name = "${local.name_prefix}-igw"
  })
}

# Subnets for each VM
resource "aws_subnet" "vm_subnets" {
  count             = length(var.vm_config)
  vpc_id            = local.use_existing_vpc ? data.aws_vpc.existing[0].id : aws_vpc.main[0].id
  cidr_block        = local.use_existing_vpc ? var.vm_config[count.index].network.existing_vpc.subnet_cidr : var.vm_config[count.index].network.new_vpc.subnet_cidr
  availability_zone = data.aws_availability_zones.available.names[count.index % length(data.aws_availability_zones.available.names)]
  map_public_ip_on_launch = var.vm_config[count.index].enable_public_ip
  tags = merge(var.tags, {
    Name = "${local.name_prefix}-subnet-${count.index + 1}"
  })
}

# Route Table (only if use_existing_vpc = false)
resource "aws_route_table" "public" {
  count  = local.use_existing_vpc ? 0 : 1
  vpc_id = aws_vpc.main[0].id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main[0].id
  }
  tags = merge(var.tags, {
    Name = "${local.name_prefix}-rt-public"
  })
}

# Route Table Association (only if use_existing_vpc = false)
resource "aws_route_table_association" "public" {
  count          = local.use_existing_vpc ? 0 : length(var.vm_config)
  subnet_id      = aws_subnet.vm_subnets[count.index].id
  route_table_id = aws_route_table.public[0].id
}

# Security Group (always create new for this env)
resource "aws_security_group" "main" {
  name_prefix = "${local.name_prefix}-sg"
  vpc_id      = local.use_existing_vpc ? (length(data.aws_vpc.existing) > 0 ? data.aws_vpc.existing[0].id : null) : aws_vpc.main[0].id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = merge(var.tags, {
    Name = "${local.name_prefix}-sg"
  })
}

# Key Pair
resource "aws_key_pair" "main" {
  key_name   = "${local.name_prefix}-key"
  public_key = file("~/.ssh/id_rsa.pub")
}

# EC2 Instances
resource "aws_instance" "main" {
  count         = length(var.vm_config)
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.vm_config[count.index].instance_type
  subnet_id     = aws_subnet.vm_subnets[count.index].id
  vpc_security_group_ids = [aws_security_group.main.id]
  key_name               = aws_key_pair.main.key_name
  monitoring             = var.vm_config[count.index].enable_monitoring
  tags = merge(var.tags, {
    Name = var.vm_config[count.index].instance_name
  })
  user_data = <<-EOF
              #!/bin/bash
              apt-get update
              apt-get install -y apache2
              systemctl start apache2
              systemctl enable apache2
              EOF
  root_block_device {
    volume_size = var.vm_config[count.index].os_disk_size_gb
    volume_type = "gp3"
  }
}

# CloudWatch Log Group (if monitoring enabled)
resource "aws_cloudwatch_log_group" "main" {
  count             = var.enable_monitoring ? 1 : 0
  name              = "/aws/ec2/${local.name_prefix}"
  retention_in_days = 30
  tags = var.tags
}

data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
} 