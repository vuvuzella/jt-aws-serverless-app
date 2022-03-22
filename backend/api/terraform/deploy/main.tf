variable "environment" {
  type = string
  description = "environment this deployment is done to"
}

provider "aws" {
  region = "ap-southeast-2"
  profile = "admin-dev"
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

# ---------------------------------
# Sample lambda
# ---------------------------------
module "helloWorld" {
  source            = "../../../../../modules/lambda_endpoint"
  app_artifact      = "../../../../../../artifacts/app.zip"
  app_dep_artifact  = "../../../../../../artifacts/dependencies.zip"
  app_handler       = "index.helloWorld"
  api_gateway_id    = module.apigw.id
  http_method       = "ANY"
  route             = "example/helloworld"
  lambda_name       = "HelloWorld"
}

module "apigw" {
  source = "../../../../../modules/api_gateway"
}
