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

variable "vaultwarden_config" {
  sensitive = true
  type = object({
    admin_token    = string
    smtp_host      = string
    smtp_port      = number
    smtp_from_name = string
    smtp_username  = string
    smtp_password  = string
    smtp_timeout   = optional(number, 15)
  })
}

variable "pgadmin_password" {
  description = "password for pgadmin"
  type        = string
}

variable "keel_config" {
  sensitive   = true
  description = "keel admin config"
  type = object({
    username = string
    password = string
  })
}

variable "discord_webhook_url" {
  description = "webhook url of the channel you want to have diun notify"
  sensitive   = true
  type        = string
}
