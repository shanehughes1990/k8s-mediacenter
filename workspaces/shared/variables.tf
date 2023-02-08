variable "directory_config" {
  sensitive = true
  type = object({
    appdata   = string
    media     = string
    tv_shows  = string
    movies    = string
    downloads = string
    metadata  = string
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
}
