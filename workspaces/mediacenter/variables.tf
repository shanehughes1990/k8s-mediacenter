variable "directory_config" {
  sensitive = true
  type = object({
    appdata     = string
    media       = string
    tv_shows    = string
    movies      = string
    downloads   = string
    transcoding = string
    metadata    = string
  })
}

variable "plex_claim" {
  sensitive = true
  type      = string
}

variable "domain_name" {
  sensitive   = true
  description = "DNS root/suffix domain to apply to workspace"
  type = object({
    name = string
    # zone_id = string
  })
}
