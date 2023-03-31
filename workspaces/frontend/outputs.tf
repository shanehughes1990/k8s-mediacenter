output "organizr" {
  sensitive = true
  value = {
    dns = cloudflare_record.organizr.name
  }
}
