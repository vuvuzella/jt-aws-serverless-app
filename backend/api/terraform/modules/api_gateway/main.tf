terraform {
  required_version = "~>1.1.6"
  required_providers {
    aws = {
      source ="hashicorp/aws"
      version = "~>3.73.0"
    }
  }
}

# Ref: https://docs.aws.amazon.com/apigateway/latest/developerguide/http-api-develop.html
# Tf: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/apigatewayv2_api
# Minimum requirements of a functional api:
# At least 1 of each:
# 1. route
# 2. integration
# 3. stage
# 4. deployment
data "aws_vpc" "main_network" {
  id = "vpc-089db66b70fffa9df"
}

data "aws_subnet_ids" "main_subnets" {
  vpc_id = "vpc-089db66b70fffa9df" 
}

resource "aws_apigatewayv2_api" "serverless_api" {
  name = "serverless_api"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_stage" "gw_stage" {
  api_id = aws_apigatewayv2_api.serverless_api.id
  name = "gw_stage"
  auto_deploy = true
}

output "id" {
  value = aws_apigatewayv2_api.serverless_api.id
}

output "arn" {
  value = aws_apigatewayv2_api.serverless_api.arn
}

output "execution_arn" {
  value = aws_apigatewayv2_api.serverless_api.execution_arn
}
