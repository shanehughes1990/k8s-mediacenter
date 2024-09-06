variable "directory_config" {
  sensitive = false
  type = object({
    appdata = string
    media   = string
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

variable "discord_webhook_url" {
  description = "webhook url of the channel you want to have diun notify"
  sensitive   = true
  type        = string
}
