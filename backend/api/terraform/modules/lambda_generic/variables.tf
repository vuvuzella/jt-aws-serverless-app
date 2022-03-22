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
  description = "The name of the lambda function"
}
