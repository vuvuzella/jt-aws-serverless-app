variable "endpoints" {
  type = list(object({
    invoke_uri = string
    integration_method = string
  }))
}
