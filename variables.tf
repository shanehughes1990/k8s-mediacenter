variable "provider_config" {
  sensitive = true
  type = object({
    kubernetes = object({
      host                   = string
      token                  = string
      cluster_ca_certificate = string
    })
    cloudflare = object({
      email     = string
      zone_name = string
      api_token = string
    })
  })
}

variable "directory_config" {
  sensitive = true
  type = object({
    appdata     = string
    tv_shows    = string
    movies      = string
    downloads   = string
    transcoding = string
    metadata    = string
  })
}
