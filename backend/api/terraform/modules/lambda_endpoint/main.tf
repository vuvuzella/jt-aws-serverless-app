variable "api_gateway_id" {
  type = string
  description = "The api gateway id"
}

variable "http_method" {
  type = string
  description = "Can be any of the available HTTP standard methods"
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


module "lambda_generic" {
  source            = "../lambda_generic"
  app_artifact      = var.app_artifact
  app_dep_artifact  = var.app_dep_artifact
  app_handler       = var.app_handler
}

resource "aws_apigatewayv2_integration" "endpoints" {

  api_id                      = var.api_gateway_id
  description                 = "a lambda endpoint"
  integration_type            = "HTTP_PROXY"
  connection_type             = "INTERNET"
  content_handling_strategy   = "CONVERT_TO_TEXT"
  integration_method          = var.http_method
  integration_uri             = module.lambda_generic.invoke_arn
  passthrough_behavior        = "WHEN_NO_MATCH" 

}

resource "aws_apigatewayv2_route" "routes" {
  api_id    = var.api_gateway_id
  route_key = "${upper(var.http_method)} ${var.route}"
  target    = "integrations/${aws_apigatewayv2_integration.endpoints.id}"
}
