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
