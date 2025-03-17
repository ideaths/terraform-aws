# ===============================================
# Cấu hình cơ bản - Môi trường và Region
# ===============================================
aws_region  = "ap-southeast-1"
environment = "dev"    # Các giá trị: dev, staging, prod

# ===============================================
# Cấu hình mạng - VPC, Subnet, AZ
# ===============================================
vpc_name              = "app-vpc-dev"
vpc_cidr              = "10.0.0.0/16"

# Cấu hình subnet phù hợp với 3 AZ
public_subnets        = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
private_subnets       = ["10.0.10.0/24", "10.0.11.0/24", "10.0.12.0/24"]
availability_zones    = ["ap-southeast-1a", "ap-southeast-1b", "ap-southeast-1c"]

# ===============================================
# EC2 Configuration
# ===============================================
ec2_instance_type     = "t3.small"   # Chọn t3.micro cho môi trường dev, t3.small hoặc lớn hơn cho prod
ec2_key_name          = "my-app-key" # Đảm bảo key pair này đã được tạo trên AWS

# ===============================================
# EKS Configuration
# ===============================================
cluster_name         = "app-eks-dev"
eks_version          = "1.28"       # Phiên bản Kubernetes
instance_types       = ["t3.medium"] # Loại instance cho EKS node group

# ===============================================
# RDS Configuration
# ===============================================
rds_engine           = "mysql"     # mysql hoặc postgres
rds_engine_version   = "8.0"       # Phiên bản MySQL
rds_instance_class   = "db.t3.small" # Nhỏ cho dev, lớn hơn cho prod
rds_database_name    = "appdb"
rds_username         = "admin"     # Tên đăng nhập chính
rds_password         = "YourStrongPasswordHere123!" # Thay đổi trong môi trường thực tế, tốt nhất là lấy từ AWS Secrets Manager

# ===============================================
# DynamoDB Configuration
# ===============================================
dynamodb_table_name  = "app-data-table"

# ===============================================
# S3 Configuration
# ===============================================
s3_bucket_name       = "app-assets-bucket" # Sẽ tự động thêm suffix -dev, -staging, hoặc -prod

# ===============================================
# Route53 & Domain Configuration
# ===============================================
domain_name          = "example.com" # Thay bằng tên miền thực của bạn

# ===============================================
# Tags chung
# ===============================================
default_tags = {
  Environment = "dev"
  Project     = "appname"
  Owner       = "devops-team"
  ManagedBy   = "terraform"
  CostCenter  = "it-infrastructure"
}

# Lưu ý:
# 1. Không commit file này vào git repository
# 2. Đặt password và thông tin nhạy cảm khác trong AWS Secrets Manager
# 3. Tạo các phiên bản khác nhau của file này cho các môi trường khác nhau:
#    - terraform.dev.tfvars
#    - terraform.staging.tfvars
#    - terraform.prod.tfvars
