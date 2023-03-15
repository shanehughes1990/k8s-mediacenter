variable "directory_config" {
  sensitive = false
  type = object({
    appdata   = string
    downloads = string
    media     = string
    tv_shows  = string
    movies    = string
  })
}

variable "plex_claim" {
  sensitive = true
  type      = string
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

variable "basic_auth" {
  description = "contents of an htpasswd file"
  type = object({
    username = string
    password = string
  })
}
