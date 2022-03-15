terraform {
  backend "s3" {}
}
output "Hello" {
  value = "Hello World"
}
