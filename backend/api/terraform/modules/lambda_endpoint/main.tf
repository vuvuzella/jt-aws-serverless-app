variable "api_gateway_id" {
  type = string
  description = "The api gateway id"
}

variable "route" {
  type = string
  description = "The route of the endpoint"
}

variable "app_artifact" {
  type = string
  description = "Path to the packaged application artifact"
}

variable "app_dep_artifact" {
  type = string
  description = "Path to the packaged application dependencies artifact"
}

variable "app_handler" {
  type = string
  description = "The dot notation to the handler for this lambda"
}

variable "lambda_name" {
  type = string
  description = "The name of the lambda functions"
}

variable "api_gateway_execution_arn" {
  type = string
  description = "The arn of the api gateway this lambda is attaching to"
}

module "lambda_generic" {
  source            = "../lambda_generic"
  app_artifact      = var.app_artifact
  app_dep_artifact  = var.app_dep_artifact
  app_handler       = var.app_handler
  lambda_name       = var.lambda_name
}

resource "aws_apigatewayv2_integration" "endpoints" {
  api_id                      = var.api_gateway_id
  description                 = "a lambda endpoint"
  integration_type            = "AWS_PROXY"
  connection_type             = "INTERNET"
  integration_method          = "POST"
  integration_uri             = module.lambda_generic.invoke_arn
  passthrough_behavior        = "WHEN_NO_MATCH" 

}

resource "aws_apigatewayv2_route" "routes" {
  api_id    = var.api_gateway_id
  route_key = "ANY /{proxy+}"
  target    = "integrations/${aws_apigatewayv2_integration.endpoints.id}"
}

resource "aws_lambda_permission" "api_gw_invoke" {
  statement_id = "${var.lambda_name}-AllowExecutionFromApiGateway"
  action = "lambda:InvokeFunction"
  function_name = module.lambda_generic.function_name
  principal = "apigateway.amazonaws.com"
  source_arn = "${var.api_gateway_execution_arn}/*/*"

}

output "lambda_generic" {
  value = module.lambda_generic
}
