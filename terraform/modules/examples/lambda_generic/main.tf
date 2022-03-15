provider "aws" {
  region = "ap-southeast-2"
  profile = "admin-dev"
}

terraform {
  backend "s3" {}
}

variable "app_artifact" {
  type = string
}

variable "app_dep_artifact" {
  type=string
}

module "lambda_generic" {
  source = "../../lambda_generic"
  app_artifact = var.app_artifact
  app_dep_artifact = var.app_dep_artifact
}
