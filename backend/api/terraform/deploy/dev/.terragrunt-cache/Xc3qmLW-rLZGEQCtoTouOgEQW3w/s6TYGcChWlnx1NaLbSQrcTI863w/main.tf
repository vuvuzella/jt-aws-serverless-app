variable "environment" {
  type = string
  description = "environment this deployment is done to"
}

provider "aws" {
  region = "ap-southeast-2"
  default_tags {
    tags = {
      Environment = var.environment
      Owner = "JT"
      Project = "Production-Grade Microservices Application"
    }
  }
}

terraform {
  backend "s3" {}
  required_version = "~>1.1.6"
  required_providers {
    aws = {
      source ="hashicorp/aws"
      version = "~>3.73.0"
    }
  }
}

output "Environment" {
  value = var.environment
}
