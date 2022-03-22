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

resource "aws_apigatewayv2_api" "serverless_api" {
  name = "serverless_api"
  protocol_type = "HTTP"
}

output "id" {
  value = aws_apigatewayv2_api.serverless_api.id
}
