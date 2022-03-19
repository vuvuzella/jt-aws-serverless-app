remote_state {
  backend = "s3"
  config = {
    bucket = "admin-dev-projects-tfstates"
    key = "serverless_app/${path_relative_to_include()}/terraform.tfstate"
    region = "ap-southeast-2"
    encrypt = true
    dynamodb_table = "admin-dev-projects-locks"
    profile = "admin-dev"
  }
}
