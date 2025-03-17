terraform {
  backend "s3" {
    bucket         = "my-terraform-states"
    key            = "infrastructure/terraform.tfstate"
    region         = "ap-southeast-1"
    dynamodb_table = "terraform-state-locks"
    encrypt        = true
  }
  
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
