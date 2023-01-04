variable "cloudflare_config" {
  sensitive = true
  type = object({
    api_token = string
    email     = string
    zone_name = string
  })
}
