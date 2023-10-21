variable "directory_config" {
  sensitive = false
  type = object({
    appdata = string
    tvshows = string
    anime   = string
    movies  = string
  })
}

variable "cloudflare_zone_name" {
  sensitive = true
  type      = string
}

variable "sonarr_config" {
  sensitive = true
  type = object({
    tvshows_instance = object({
      base_url = string
      api_key  = string
    })
    anime_instance = object({
      base_url = string
      api_key  = string
    })
  })
}

variable "radarr_config" {
  sensitive = true
  type = object({
    main_instance = object({
      base_url = string
      api_key  = string
    })
  })
}

variable "prowlarr_config" {
  sensitive = true
  type = object({
    base_url = string
    api_key  = string
  })
}
