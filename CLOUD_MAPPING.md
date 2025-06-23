# Cloud Resource Mapping

| Abstraksi         | AWS                | Azure                | GCP                | AliCloud           |
|-------------------|--------------------|----------------------|--------------------|--------------------|
| VM/Instance       | EC2                | Virtual Machine      | Compute Engine     | ECS                |
| VPC/Network       | VPC                | Virtual Network      | VPC Network        | VPC                |
| Subnet            | Subnet             | Subnet               | Subnetwork         | VSwitch            |
| Security Group    | Security Group     | Network Security Gr. | Firewall           | Security Group     |
| Object Storage    | S3                 | Blob Storage         | Cloud Storage      | OSS                |
| Managed K8s       | EKS                | AKS                  | GKE                | ACK                |
| IAM User/Role     | IAM                | Azure AD/Role        | IAM                | RAM                |
| Database (RDS)    | RDS                | Azure SQL/DB         | Cloud SQL          | RDS                |

---
- Gunakan tabel ini untuk mapping variable dan resource saat extend ke multi-cloud.
- Pastikan variable di module sudah cukup generik agar mudah diadaptasi ke provider lain. 