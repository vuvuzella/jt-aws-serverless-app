provider "aws" {
  region = "ap-southeast-2"
  profile = "admin-dev"
}

terraform {
  backend "s3" {
    bucket = "admin-dev-projects-tfstates"
    region = "ap-southeast-2"
    dynamodb_table = "admin-dev-projects-locks"
    encrypt = true
    profile = "admin-dev"
    key = "serverless_app/cicd/terraform.tfstate"
  }
}

data "aws_s3_bucket" "artifacts_bucket" {
  bucket = "global-infrastructure-artifacts"
}

data "aws_ssm_parameter" "github_access" {
  name = "/github/cicd/access-token"
}

resource "aws_iam_role" "cicd_role" {
  name = "cicd_serverless_app_role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codebuild.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

// TODO: determine actions for this role
resource "aws_iam_role_policy" "cicd_policy" {
  role = aws_iam_role.cicd_role.name
  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Resource": ["*"],
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ]
    },
    {
      "Effect": "Allow",
      "Resource": ["*"],
      "Action": [
        "ssm:GetParameters"
      ]
    }

  ]
}
POLICY
}

resource "aws_codebuild_project" "serverless_app_cicd" {
  name = "serverless_app"
  description = "example serverless application"
  build_timeout = 5
  service_role = aws_iam_role.cicd_role.arn
  artifacts {
    type = "NO_ARTIFACTS"
  }

  // cache {
  //   // TODO: know what this is for
  // }

  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    image = "aws/codebuild/standard:5.0"
    type = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
    environment_variable {
      name = "SOME_VARIABLE"
      value = "HELLO WORLD!"
    }
  }

  logs_config {
    cloudwatch_logs {
      group_name = "cicd_serverless_app"
      stream_name = "cicd_streams"
    }

    s3_logs {
      status = "ENABLED"
      location = "${data.aws_s3_bucket.artifacts_bucket.id}/serverless_app/logs/build"
    }
  }

  source {
    type = "GITHUB"
    location = "https://github.com/vuvuzella/jt-aws-serverless-app.git"
    buildspec = "cicd/deploy.buildspec.yml"
    git_clone_depth = 0
    report_build_status = true
  }

}

resource aws_codebuild_source_credential "github_access" {
  auth_type = "PERSONAL_ACCESS_TOKEN"
  server_type = "GITHUB"
  token = data.aws_ssm_parameter.github_access.value
  user_name = "vuvuzella"

}


// resource "aws_codebuild_webhook" "cb_webhook" {
//   // TODO
// }

// TODO: Create a Codebuild Service Role
