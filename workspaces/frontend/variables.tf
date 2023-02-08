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

variable "cloudflare_config" {
  sensitive = false
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
