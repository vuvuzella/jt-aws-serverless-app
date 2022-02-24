provider "aws" {
  region = "ap-southeast-2"
  profile = "admin-dev"

}


terraform {
  backend "s3" {
  }

  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 3.0"
    }
    circleci = {
      source = "TomTucka/circleci"
      version = "~> 0.5.0"
    }
  }
}

#----------------------------------
# using codebuild as ci
#----------------------------------
// module "codebuild" {
//   source = "./codebuild"
// }


#----------------------------------
# using codebuild as ci
#----------------------------------
module "circleci" {
  source = "./circleci"
  api_token = var.circleci_api_token
}

variable "circleci_api_token" {
  type = string
  default = ""
}
