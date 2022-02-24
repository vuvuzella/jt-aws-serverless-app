provider "aws" {
  region = "ap-southeast-2"
  profile = "admin-dev"

}

provider "circleci" {
  token = ""
  organization = "vuvuzella"
  vcs_type = "github"
  
}
terraform {
  backend "s3" {
  }

  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

#----------------------------------
# using codebuild as ci
#----------------------------------
// module "codebuild" {
//   source = "./codebuild"
// }
