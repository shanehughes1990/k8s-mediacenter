variable "cloud_sql_proxy_config" {
  sensitive = true
  type = object({
    base64_encoded_application_credentials = string
    instances                              = list(string)
  })
}
