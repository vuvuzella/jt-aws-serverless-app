provider "aws" {
  region = "ap-southeast-2"
  profile = "admin-dev"
}

terraform {

  required_version = "~>1.1.6"
  required_providers {
    aws = {
      source ="hashicorp/aws"
      version = "~>3.73.0"
    }
  }
  backend "s3" {}

}

resource "aws_lambda_function" "serverless_app" {
  filename = "app.zip"
  function_name = "serverless-lambda"
  role = aws_iam_role.lambda_role.arn
  handler = "index.handler"
  source_code_hash = filebase64sha256("../../artifacts/app.zip")
  runtime = "nodejs14.x"
  layers = [aws_lambda_layer_version.dependencies.arn]
  environment {
    variables = {
      HELLO="HELLO WORLD"
    }
  }

  vpc_config {
    // TODO
    subnet_ids = data.aws_subnet_ids.main_subnets.ids
    security_group_ids = [aws_security_group.lambda_sg.id]
  }

}

resource "aws_security_group" "lambda_sg" {
  name = "lambda_sg"
  description = "example security group"
  vpc_id = data.aws_vpc.main_network.id

  // create a resource inside the VPC where this lambda will connect to
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_iam_role" "lambda_role" {
  name = "iam_role_lambda"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
  EOF
}

// This is needed if we want to deploy a lambda that connects to a VPC
resource "aws_iam_role_policy_attachment" "AWSLambdaVPCAccessExecutionRole" {
    role       = aws_iam_role.lambda_role.name
    policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

resource "aws_lambda_function_event_invoke_config" "example" {
  function_name = aws_lambda_function.serverless_app.function_name
  maximum_retry_attempts = 0
}

resource "aws_lambda_layer_version" "dependencies" {
  filename = "../../artifacts/dependencies.zip"
  layer_name = "serverless_app_dependencies"

  compatible_runtimes = ["nodejs14.x"]
}
