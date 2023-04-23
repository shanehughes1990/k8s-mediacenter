output "organizr" {
  sensitive = true
  value = {
    dns = "web.${var.cloudflare_config.zone_name}"
    middlewares = {
      auth_admin = {
        name      = kubernetes_manifest.organizr_forward_auth_admin.manifest.metadata.name
        namespace = kubernetes_manifest.organizr_forward_auth_admin.manifest.metadata.namespace
      }
    }
  }
}
