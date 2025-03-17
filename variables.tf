# --- variables.tf ---
variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "ap-southeast-1"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "rds_engine" {
  description = "Database engine type"
  type        = string
  default     = "mysql"
}

variable "rds_engine_version" {
  description = "Database engine version"
  type        = string
  default     = "8.0"
}

variable "rds_instance_class" {
  description = "Database instance type"
  type        = string
  default     = "db.t3.small"
}

variable "rds_database_name" {
  description = "Name of the database"
  type        = string
  default     = "mydb"
}

variable "rds_username" {
  description = "Database master username"
  type        = string
  default     = "admin"
  sensitive   = true
}

variable "rds_password" {
  description = "Database master password"
  type        = string
  default     = null
  sensitive   = true
}

variable "domain_name" {
  description = "Domain name for Route 53 and ACM"
  type        = string
  default     = "example.com"
}

variable "dynamodb_table_name" {
  description = "Name for the DynamoDB table"
  type        = string
  default     = "my-dynamodb-table"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "vpc_name" {
  description = "Name for the VPC"
  type        = string
  default     = "main-vpc"
}

variable "public_subnets" {
  description = "List of public subnet CIDR blocks"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "private_subnets" {
  description = "List of private subnet CIDR blocks"
  type        = list(string)
  default     = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
  default     = ["ap-southeast-1a", "ap-southeast-1b", "ap-southeast-1c"]
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = "main-eks-cluster"
}

variable "eks_version" {
  description = "Kubernetes version for EKS cluster"
  type        = string
  default     = "1.28"
}

variable "instance_types" {
  description = "Instance types for EKS node groups"
  type        = list(string)
  default     = ["t3.medium"]
}

variable "ec2_instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "ec2_key_name" {
  description = "EC2 key pair name"
  type        = string
  default     = "my-key-pair"
}

variable "s3_bucket_name" {
  description = "Name for the S3 bucket"
  type        = string
  default     = "my-app-bucket"
}

variable "default_tags" {
  description = "Default tags for all resources"
  type        = map(string)
  default = {
    Environment = "dev"
    Project     = "terraform-aws-infra"
    Terraform   = "true"
  }
}
