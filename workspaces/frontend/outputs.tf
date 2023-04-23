output "organizr" {
  sensitive = true
  value = {
    dns = "web.${var.cloudflare_config.zone_name}"
  }
}
