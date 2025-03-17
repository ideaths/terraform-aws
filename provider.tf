# --- provider.tf ---
provider "aws" {
  region = var.aws_region
  default_tags {
    tags = var.default_tags
  }

# RDS Database Instance with Security Group
module "rds_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.1.0"

  name        = "rds-sg"
  description = "Security group for RDS instance"
  vpc_id      = module.vpc.vpc_id

  # Allow MySQL/PostgreSQL from private subnets
  ingress_with_cidr_blocks = [
    {
      from_port   = 3306
      to_port     = 3306
      protocol    = "tcp"
      description = "MySQL access from private subnets"
      cidr_blocks = join(",", var.private_subnets)
    },
    {
      from_port   = 5432
      to_port     = 5432
      protocol    = "tcp"
      description = "PostgreSQL access from private subnets"
      cidr_blocks = join(",", var.private_subnets)
    }
  ]
}

module "rds" {
  source  = "terraform-aws-modules/rds/aws"
  version = "6.3.0"

  identifier = "rds-${var.environment}"

  engine               = var.rds_engine
  engine_version       = var.rds_engine_version
  family               = "${var.rds_engine}${split(".", var.rds_engine_version)[0]}"
  major_engine_version = split(".", var.rds_engine_version)[0]
  instance_class       = var.rds_instance_class

  allocated_storage     = 20
  max_allocated_storage = 100
  storage_encrypted     = true

  db_name  = var.rds_database_name
  username = var.rds_username
  password = var.rds_password
  port     = var.rds_engine == "mysql" ? 3306 : 5432

  multi_az               = var.environment == "prod"
  db_subnet_group_name   = module.vpc.database_subnet_group
  vpc_security_group_ids = [module.rds_sg.security_group_id]

  maintenance_window = "Mon:00:00-Mon:03:00"
  backup_window      = "03:00-06:00"
  backup_retention_period = 7

  tags = {
    Environment = var.environment
    Name        = "rds-${var.environment}"
  }
}

# DynamoDB
module "dynamodb" {
  source  = "terraform-aws-modules/dynamodb-table/aws"
  version = "3.3.0"

  name     = "${var.dynamodb_table_name}-${var.environment}"
  hash_key = "id"

  attributes = [
    {
      name = "id"
      type = "S"
    }
  ]

  billing_mode = "PAY_PER_REQUEST"

  point_in_time_recovery_enabled = true
  server_side_encryption_enabled = true

  tags = {
    Environment = var.environment
    Name        = "${var.dynamodb_table_name}-${var.environment}"
  }
}

# ECR Repository
module "ecr" {
  source  = "terraform-aws-modules/ecr/aws"
  version = "1.6.0"

  repository_name = "app-repository-${var.environment}"
  
  repository_lifecycle_policy = jsonencode({
    rules = [
      {
        rulePriority = 1,
        description  = "Keep last 30 images",
        selection = {
          tagStatus     = "any",
          countType     = "imageCountMoreThan",
          countNumber   = 30
        },
        action = {
          type = "expire"
        }
      }
    ]
  })

  tags = {
    Environment = var.environment
  }
}

# Elasticache - Redis
module "elasticache_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.1.0"

  name        = "elasticache-sg"
  description = "Security group for Elasticache Redis"
  vpc_id      = module.vpc.vpc_id

  ingress_with_cidr_blocks = [
    {
      from_port   = 6379
      to_port     = 6379
      protocol    = "tcp"
      description = "Redis access from private subnets"
      cidr_blocks = join(",", var.private_subnets)
    }
  ]
}

module "elasticache" {
  source  = "cloudposse/elasticache-redis/aws"
  version = "0.56.0"

  namespace              = "app"
  stage                  = var.environment
  name                   = "redis"
  availability_zones     = var.availability_zones
  vpc_id                 = module.vpc.vpc_id
  subnets                = module.vpc.private_subnets
  cluster_size           = 1
  instance_type          = "cache.t3.small"
  apply_immediately      = true
  automatic_failover_enabled = var.environment == "prod"
  engine_version         = "6.x"
  family                 = "redis6.x"
  at_rest_encryption_enabled = true
  transit_encryption_enabled  = true
  security_group_ids     = [module.elasticache_sg.security_group_id]

  tags = {
    Environment = var.environment
  }
}

# CloudFront Distribution with S3 origin
module "cloudfront" {
  source  = "terraform-aws-modules/cloudfront/aws"
  version = "3.2.1"

  aliases = ["cdn.${var.domain_name}"]

  comment             = "CloudFront for ${var.environment}"
  enabled             = true
  price_class         = "PriceClass_100"
  retain_on_delete    = false
  wait_for_deployment = false

  create_origin_access_identity = true
  origin_access_identities = {
    s3_bucket = "Access identity for S3 bucket"
  }

  origin = {
    s3_bucket = {
      domain_name = module.s3_bucket.s3_bucket_bucket_regional_domain_name
      s3_origin_config = {
        origin_access_identity = "s3_bucket"
      }
    }
  }

  default_cache_behavior = {
    target_origin_id       = "s3_bucket"
    viewer_protocol_policy = "redirect-to-https"

    allowed_methods = ["GET", "HEAD", "OPTIONS"]
    cached_methods  = ["GET", "HEAD"]
    compress        = true
    query_string    = true
  }

  viewer_certificate = {
    acm_certificate_arn = module.acm.acm_certificate_arn
    ssl_support_method  = "sni-only"
  }

  tags = {
    Environment = var.environment
  }
}

# CloudWatch Alarms
module "cloudwatch_alarms" {
  source  = "terraform-aws-modules/cloudwatch/aws//modules/metric-alarm"
  version = "4.3.0"

  alarm_name          = "high-cpu-usage-${var.environment}"
  alarm_description   = "High CPU usage for EC2 instance"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  threshold           = 80
  period              = 120
  unit                = "Percent"

  namespace   = "AWS/EC2"
  metric_name = "CPUUtilization"
  statistic   = "Average"

  dimensions = {
    InstanceId = module.ec2_instance.id
  }

  alarm_actions = []

  tags = {
    Environment = var.environment
  }
}

# AWS Secrets Manager for storing sensitive information
module "secrets_manager" {
  source  = "terraform-aws-modules/secrets-manager/aws"
  version = "1.1.1"

  name_prefix = "app-secrets-${var.environment}"
  description = "Secrets for application in ${var.environment} environment"
  
  recovery_window_in_days = 7
  
  # Define your secrets
  secret_string = jsonencode({
    db_username     = var.rds_username,
    db_password     = var.rds_password,
    api_key         = "EXAMPLE-API-KEY",
    another_secret  = "another-value"
  })
  
  tags = {
    Environment = var.environment
  }
}

# Simple lambda function with API Gateway
module "lambda_function" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "6.0.0"

  function_name = "api-function-${var.environment}"
  description   = "API Lambda function"
  handler       = "index.handler"
  runtime       = "nodejs18.x"

  source_path = "./lambda"

  attach_policy_statements = true
  policy_statements = {
    dynamodb = {
      effect    = "Allow",
      actions   = ["dynamodb:GetItem", "dynamodb:PutItem", "dynamodb:DeleteItem", "dynamodb:Scan", "dynamodb:Query"],
      resources = [module.dynamodb.dynamodb_table_arn]
    }
  }

  tags = {
    Environment = var.environment
  }
}

module "api_gateway" {
  source  = "terraform-aws-modules/apigateway-v2/aws"
  version = "2.2.2"

  name          = "api-gateway-${var.environment}"
  description   = "HTTP API Gateway"
  protocol_type = "HTTP"

  cors_configuration = {
    allow_headers = ["content-type", "x-amz-date", "authorization", "x-api-key"]
    allow_methods = ["*"]
    allow_origins = ["*"]
  }

  integrations = {
    "POST /items" = {
      lambda_arn = module.lambda_function.lambda_function_arn
    }
    
    "GET /items" = {
      lambda_arn = module.lambda_function.lambda_function_arn
    }
    
    "GET /items/{id}" = {
      lambda_arn = module.lambda_function.lambda_function_arn
    }
  }

  tags = {
    Environment = var.environment
  }
}

# SQS Queue for async processing
module "sqs" {
  source  = "terraform-aws-modules/sqs/aws"
  version = "4.1.0"

  name = "app-queue-${var.environment}"
  
  fifo_queue           = false
  visibility_timeout_seconds = 30
  message_retention_seconds  = 86400 # 1 day

  tags = {
    Environment = var.environment
  }
}

# WAF for protection
module "waf" {
  source  = "terraform-aws-modules/waf/aws"
  version = "3.3.0"

  name        = "app-waf-${var.environment}"
  description = "WAF for protecting application resources"
  scope       = "REGIONAL"

  rules = [
    {
      name     = "AWSManagedRulesCommonRuleSet"
      priority = 1

      override_action = "none"

      statement = {
        managed_rule_group_statement = {
          name        = "AWSManagedRulesCommonRuleSet"
          vendor_name = "AWS"
        }
      }

      visibility_config = {
        cloudwatch_metrics_enabled = true
        metric_name                = "AWSManagedRulesCommonRuleSet"
        sampled_requests_enabled   = true
      }
    }
  ]

  visibility_config = {
    cloudwatch_metrics_enabled = true
    metric_name                = "app-waf-${var.environment}"
    sampled_requests_enabled   = true
  }

  tags = {
    Environment = var.environment
  }
}
}

terraform {
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
  
  backend "s3" {
    bucket         = "terraform-state-bucket-name"
    key            = "terraform.tfstate"
    region         = "ap-southeast-1"
    dynamodb_table = "terraform-lock-table"
    encrypt        = true
  }
}
