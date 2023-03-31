variable "directory_config" {
  sensitive = false
  type = object({
    appdata = string
  })
}

variable "cloud_sql_proxy_config" {
  sensitive = true
  type = object({
    base64_encoded_application_credentials = string
    instances                              = list(string)
  })
}

variable "discord_webhook_url" {
  description = "webhook url of the channel you want to have diun notify"
  sensitive   = true
  type        = string
}

variable "postgres_config" {
  description = "postgres database configuration"
  sensitive   = true
  type = object({
    username = string
    password = string
  })
}
