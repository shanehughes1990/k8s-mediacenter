variable "directory_config" {
  sensitive = true
  type = object({
    appdata     = string
    media       = string
    tv_shows    = string
    movies      = string
    downloads   = string
    transcoding = string
    metadata    = string
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
