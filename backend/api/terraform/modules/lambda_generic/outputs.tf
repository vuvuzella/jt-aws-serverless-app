output "invoke_arn" {
  value = aws_lambda_function.serverless_app.invoke_arn
}

output "function_name" {
  value = aws_lambda_function.serverless_app.function_name
}
