variable "provider_config" {
  sensitive = true
  type = object({
    kubernetes = object({
      host                   = string
      token                  = string
      cluster_ca_certificate = string
    })
    cloudflare = object({
      zone_name = string
      api_token = string
    })
  })
}

variable "acme_email" {
  sensitive = true
  type      = string
}
