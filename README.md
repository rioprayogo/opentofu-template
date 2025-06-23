# OpenTofu Multi-Cloud Infrastructure

## Deskripsi
Repositori ini berisi workflow Infrastructure as Code (IaC) menggunakan OpenTofu/Terraform untuk provisioning resource di AWS (dan cloud lain jika diperlukan). Mendukung workflow pengembangan lokal dengan LocalStack dan deployment ke AWS asli.

## Struktur Folder
- `environments/` : Konfigurasi per-environment (dev, staging, prod)
- `modules/`      : Kumpulan module reusable (AWS, dsb)
- `main.tf`       : Entry point root module
- `variables.tf`  : Definisi variable global

## Setup
1. Install [OpenTofu](https://opentofu.org/) atau Terraform.
2. (Opsional) Install [LocalStack](https://docs.localstack.cloud/getting-started/) untuk testing lokal.
3. Clone repo ini dan masuk ke folder project.

## Menjalankan di LocalStack
1. Jalankan LocalStack (`localstack start` atau via Docker).
2. Edit `environments/dev/terraform.tfvars`:
   - `aws_use_localstack = true`
   - `kubernetes_config = []`
   - `enable_monitoring = false`
3. Jalankan:
   ```sh
   cd environments/dev
   tofu init
   tofu apply -auto-approve
   tofu destroy -auto-approve
   ```

## Menjalankan di AWS
1. Pastikan AWS credentials sudah benar.
2. Edit `environments/dev/terraform.tfvars`:
   - `aws_use_localstack = false`
   - Isi variable lain sesuai kebutuhan.
3. Jalankan:
   ```sh
   cd environments/dev
   tofu init
   tofu apply -auto-approve
   tofu destroy -auto-approve
   ```

## Kontribusi
Pull request dan issue sangat diterima!

## Lisensi
Lihat file LICENSE. 