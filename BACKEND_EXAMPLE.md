# Contoh Backend Configuration

## AWS S3 Backend (untuk production/staging)
```hcl
terraform {
  backend "s3" {
    bucket = "my-tfstate-bucket"
    key    = "state/dev/terraform.tfstate"
    region = "us-east-1"
  }
}
```

## Local Backend (untuk development/local testing)
```hcl
terraform {
  backend "local" {
    path = "./terraform.tfstate"
  }
}
```

## LocalStack S3 Backend (untuk testing lokal dengan LocalStack)
```hcl
terraform {
  backend "s3" {
    bucket                      = "test-bucket"
    key                         = "state/dev/terraform.tfstate"
    region                      = "us-east-1"
    endpoint                    = "http://localhost:4566"
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    force_path_style            = true
  }
}
```

---
- Gunakan backend S3 untuk deployment production/staging di AWS asli.
- Gunakan backend local atau LocalStack untuk development/testing lokal. 