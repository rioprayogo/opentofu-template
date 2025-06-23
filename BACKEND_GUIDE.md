# Panduan Backend OpenTofu/Terraform

## 1. Setup Backend
- Pilih backend sesuai kebutuhan:
  - **Local**: Untuk development/testing lokal.
  - **S3**: Untuk production/staging di AWS.
  - **S3 LocalStack**: Untuk testing lokal dengan LocalStack.

## 2. Switching Backend
- Ubah blok `terraform { backend ... }` di file konfigurasi (lihat contoh di BACKEND_EXAMPLE.md).
- Setelah mengubah backend, jalankan:
  ```sh
  tofu init -reconfigure
  ```
- Untuk migrasi state dari local ke S3:
  ```sh
  tofu state push
  ```

## 3. Tips Troubleshooting
- **Error credential**: Pastikan AWS credentials benar atau gunakan dummy credential untuk LocalStack.
- **State lock error**: Jika pakai S3, pastikan DynamoDB lock table tersedia (atau matikan locking untuk LocalStack).
- **Endpoint error**: Untuk LocalStack, pastikan endpoint dan port sudah benar (`endpoint = "http://localhost:4566"`).
- **State file tidak ditemukan**: Jalankan `tofu init` ulang.

## 4. Best Practice
- Jangan commit file state (`terraform.tfstate`) ke git.
- Pisahkan backend untuk setiap environment.
- Dokumentasikan backend yang dipakai di setiap environment. 