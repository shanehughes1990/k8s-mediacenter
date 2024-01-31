variable "directory_config" {
  sensitive = false
  type = object({
    appdata   = string
    downloads = string
    media     = string
    tv_shows  = string
    movies    = string
    anime     = string
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

variable "grafana_config" {
  description = "Configuration for Grafana"
  sensitive   = true
  type = object({
    admin_username    = string
    admin_password    = string
    database_username = string
    database_password = string
  })
}
