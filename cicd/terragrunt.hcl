remote_state {
  backend = "s3"
  config = {
    bucket = "admin-dev-projects-tfstates"
    region = "ap-southeast-2"
    dynamodb_table = "admin-dev-projects-locks"
    encrypt = true
    profile = "admin-dev"
    key = "serverless_app/cicd/terraform.tfstate"
  }
}

inputs = {
  api_token = "Get this token from last pass circleci record"
}
