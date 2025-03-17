# --- outputs.tf ---
output "vpc_id" {
  description = "ID của VPC"
  value       = module.vpc.vpc_id
}

output "public_subnets" {
  description = "ID của các public subnet"
  value       = module.vpc.public_subnets
}

output "private_subnets" {
  description = "ID của các private subnet"
  value       = module.vpc.private_subnets
}

output "ec2_instance_id" {
  description = "ID của EC2 instance"
  value       = module.ec2_instance.id
}

output "ec2_public_ip" {
  description = "Public IP của EC2 instance"
  value       = module.ec2_instance.public_ip
}

output "eks_cluster_id" {
  description = "ID của EKS cluster"
  value       = module.eks.cluster_id
}

output "eks_cluster_endpoint" {
  description = "Endpoint của EKS cluster"
  value       = module.eks.cluster_endpoint
}

output "s3_bucket_id" {
  description = "ID của S3 bucket"
  value       = module.s3_bucket.s3_bucket_id
}

output "s3_bucket_arn" {
  description = "ARN của S3 bucket"
  value       = module.s3_bucket.s3_bucket_arn
}

output "alb_dns_name" {
  description = "DNS name của ALB"
  value       = module.alb.lb_dns_name
}

output "rds_instance_endpoint" {
  description = "Endpoint của RDS instance"
  value       = module.rds.db_instance_endpoint
}

output "rds_instance_address" {
  description = "Địa chỉ của RDS instance"
  value       = module.rds.db_instance_address
}

output "dynamodb_table_arn" {
  description = "ARN của DynamoDB table"
  value       = module.dynamodb.dynamodb_table_arn
}

output "ecr_repository_url" {
  description = "URL của ECR repository"
  value       = module.ecr.repository_url
}

output "cloudfront_distribution_id" {
  description = "ID của CloudFront distribution"
  value       = module.cloudfront.cloudfront_distribution_id
}

output "cloudfront_domain_name" {
  description = "Domain name của CloudFront distribution"
  value       = module.cloudfront.cloudfront_distribution_domain_name
}

output "domain_name" {
  description = "Domain name được cấu hình trong Route 53"
  value       = var.domain_name
}
