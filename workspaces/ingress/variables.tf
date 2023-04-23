variable "cloudflare_config" {
  sensitive = true
  type = object({
    api_token = string
    email     = string
    zone_name = string
    tls_crt   = string
    tls_key   = string
  })
}
