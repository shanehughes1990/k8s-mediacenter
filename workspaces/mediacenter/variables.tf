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

variable "sonarr_api_key" {
  description = "api key for sonarr"
  sensitive   = true
  type        = string
}

variable "radarr_api_key" {
  description = "api key for radarr"
  sensitive   = true
  type        = string
}

variable "prowlarr_config" {
  sensitive = true
  type = object({
    base_url = string
    api_key  = string
  })
}

variable "sonarr_config" {
  sensitive = true
  type = object({
    postgres_username = string
    postgres_password = string
  })
}

variable "radarr_config" {
  sensitive = true
  type = object({
    postgres_username = string
    postgres_password = string
  })
}
