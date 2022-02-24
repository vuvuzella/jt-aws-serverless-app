terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}
data "aws_s3_bucket" "artifacts_bucket" {
  bucket = "global-infrastructure-artifacts"
}

data "aws_ssm_parameter" "github_access" {
  name = "/github/cicd/access-token"
}

data "aws_vpc" "main_network" {
  id = "vpc-089db66b70fffa9df"
}

data "aws_subnets" "app_private_2a" {
  filter {
    name = "vpc-id"
    values = ["vpc-089db66b70fffa9df"]
  }

  tags = {
    Name = "app-private-ap-southeast-2a"
  }
}

data "aws_subnet" app_private_2a_arn {
  count = length(data.aws_subnets.app_private_2a.ids)
  filter {
    name = "subnet-id"
    values = [data.aws_subnets.app_private_2a.ids[count.index]]
  }
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
  policy = data.aws_iam_policy_document.cicd_policy.json
}

data "aws_iam_policy_document" "cicd_policy" {
  statement {
    effect = "Allow"
    resources = ["*"]
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
  }

  statement {
    effect = "Allow"
    resources = ["*"]
    actions = [
      "ssm:GetParameters"
    ]
  }

  statement {
    effect = "Allow"
    resources = ["*"]
    actions = [
      "ec2:CreateNetworkInterface",
      "ec2:DescribeDhcpOptions",
      "ec2:DescribeNetworkInterfaces",
      "ec2:DeleteNetworkInterface",
      "ec2:DescribeSubnets",
      "ec2:DescribeSecurityGroups",
      "ec2:DescribeVpcs"
    ]
  }

  statement {
    effect = "Allow"
    resources = ["arn:aws:ec2:ap-southeast-2:536674233911:network-interface/*"]
    actions = ["ec2:createnetworkinterfacepermission"]
    condition {
      test = "StringEquals"
      variable = "ec2:Subnet"
      
      values = "${data.aws_subnet.app_private_2a_arn[*].arn}"
    }

    condition {
      test = "StringEquals"
      variable = "ec2:AuthorizedService"

      values = ["codebuild.amazonaws.com"]
    }
  }

  statement {
    effect = "Allow"
    resources = ["${data.aws_s3_bucket.artifacts_bucket.arn}"]
    actions = ["s3:*"]
  }

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

  source_version = "master"

  vpc_config {
    vpc_id = data.aws_vpc.main_network.id
    subnets = data.aws_subnets.app_private_2a.ids
    security_group_ids = [aws_security_group.cicd_sg.id]
  }

}

resource "aws_security_group" "cicd_sg" {
  name = "cicd_serverless_sg"
  description = "sg for cicd that allows egress"
  vpc_id = data.aws_vpc.main_network.id

  egress {
    from_port = 0
    to_port = 0
    protocol = -1
    cidr_blocks = ["0.0.0.0/0"]
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

output "policy" {
  value = data.aws_iam_policy_document.cicd_policy.json
}
