# Cấu hình S3 backend cho Terraform
# File này định nghĩa nơi Terraform sẽ lưu trữ file state
# Sử dụng S3 để lưu trữ state giúp làm việc theo team và bảo vệ state file

terraform {
  backend "s3" {
    bucket         = "terraform-state-bucket-name"    # Thay thế bằng tên S3 bucket thực
    key            = "infrastructure/terraform.tfstate" # Đường dẫn trong bucket
    region         = "ap-southeast-1"                 # Region của bucket
    
    # DynamoDB table dùng để lock state, tránh xung đột khi nhiều người chạy cùng lúc
    dynamodb_table = "terraform-lock-table"          # Thay thế bằng tên bảng DynamoDB thực
    
    encrypt        = true                            # Mã hóa state file tại S3
    
    # Tùy chọn: Thêm role_arn nếu cần assume role khác để truy cập S3
    # role_arn     = "arn:aws:iam::ACCOUNT_ID:role/ROLE_NAME"
  }

  # Các cấu hình required_providers có thể giữ ở đây hoặc chuyển sang provider.tf
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.20"
    }
  }
  
  required_version = ">= 1.0.0"
}
