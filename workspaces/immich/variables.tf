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

variable "typesense_api_key" {
  sensitive   = true
  description = "API Key for typesense"
}

variable "postgres_config" {
  description = "postgres database configuration"
  sensitive   = true
  type = object({
    username = string
    password = string
  })
}
