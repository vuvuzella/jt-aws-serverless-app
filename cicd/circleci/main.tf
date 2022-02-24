provider "circleci" {
  token = var.api_token
  organization = "vuvuzella"
  vcs_type = "github"
}

terraform {
  required_providers {
    circleci = {
      source = "TomTucka/circleci"
      version = "~> 0.5.0"
    }
  }
}

resource "circleci_project" "serverless_app" {
  name = "jt-aws-serverless-app"
}

variable "api_token" {
  type = string
  default = ""
}
