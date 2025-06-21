# Local values
locals {
  name_prefix = "${var.project_name}-${var.environment}"
}

# VPC Network
resource "google_compute_network" "main" {
  name                    = "${local.name_prefix}-vpc"
  auto_create_subnetworks = false
}

# Subnets
resource "google_compute_subnetwork" "subnets" {
  count         = length(var.subnet_cidrs)
  name          = "${local.name_prefix}-subnet-${count.index + 1}"
  ip_cidr_range = var.subnet_cidrs[count.index]
  region        = var.region
  network       = google_compute_network.main.id
}

# Firewall Rules
resource "google_compute_firewall" "main" {
  name    = "${local.name_prefix}-firewall"
  network = google_compute_network.main.name

  allow {
    protocol = "tcp"
    ports    = ["22", "80", "443"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["${local.name_prefix}-instances"]
}

# Compute Instances
resource "google_compute_instance" "instances" {
  count        = var.instance_count
  name         = "${local.name_prefix}-instance-${count.index + 1}"
  machine_type = var.instance_type
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
      size  = 20
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.subnets[count.index % length(google_compute_subnetwork.subnets)].id
    access_config {
      // Ephemeral public IP
    }
  }

  metadata = {
    ssh-keys = "debian:${file("~/.ssh/id_rsa.pub")}"
  }

  metadata_startup_script = <<-EOF
              #!/bin/bash
              apt-get update
              apt-get install -y apache2
              systemctl start apache2
              systemctl enable apache2
              EOF

  tags = ["${local.name_prefix}-instances"]

  labels = var.tags
}

# Cloud Logging (if monitoring enabled)
resource "google_logging_project_sink" "main" {
  count   = var.enable_monitoring ? 1 : 0
  name    = "${local.name_prefix}-sink"
  project = data.google_project.current.project_id

  destination = "storage.googleapis.com/${google_storage_bucket.logs[0].name}"

  filter = "resource.type=gce_instance"
}

# Storage Bucket for Logs (if monitoring enabled)
resource "google_storage_bucket" "logs" {
  count   = var.enable_monitoring ? 1 : 0
  name    = "${local.name_prefix}-logs-${random_string.bucket[0].result}"
  location = var.region

  uniform_bucket_level_access = true

  lifecycle_rule {
    condition {
      age = 30
    }
    action {
      type = "Delete"
    }
  }
}

# Random string for bucket name
resource "random_string" "bucket" {
  count   = var.enable_monitoring ? 1 : 0
  length  = 8
  special = false
  upper   = false
}

# Data sources
data "google_project" "current" {} 