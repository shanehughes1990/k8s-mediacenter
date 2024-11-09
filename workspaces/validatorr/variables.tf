variable "cloudflare_config" {
  sensitive = true
  type = object({
    email     = string
    zone_name = string
    api_token = string
    zone_id   = string
  })
}
