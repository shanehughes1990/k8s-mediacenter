variable "directory_config" {
  sensitive = false
  type = object({
    appdata = string
  })
}

variable "cloudflare_config" {
  sensitive = true
  type = object({
    email     = string
    zone_name = string
    api_token = string
    zone_id   = string
  })
}

variable "cloud_sql_proxy_config" {
  sensitive = true
  type = object({
    base64_encoded_application_credentials = string
    instances                              = list(string)
  })
}

variable "postgres_config" {
  description = "postgres database configuration"
  sensitive   = true
  type = object({
    username = string
    password = string
  })
}

variable "mongo_config" {
  description = "mongo databsae configuration"
  sensitive   = true
  type = object({
    root_username = string
    root_password = string
  })
}
