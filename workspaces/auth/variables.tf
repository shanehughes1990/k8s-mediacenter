variable "directory_config" {
  sensitive = false
  type = object({
    appdata = string
  })
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

variable "authentik_config" {
  sensitive = true
  type = object({
    secret_key = string
  })
}
