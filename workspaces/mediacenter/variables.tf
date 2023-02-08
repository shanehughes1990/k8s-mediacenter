variable "directory_config" {
  sensitive = true
  type = object({
    appdata   = string
    media     = string
    tv_shows  = string
    movies    = string
    downloads = string
  })
}

variable "plex_claim" {
  sensitive = true
  type      = string
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
