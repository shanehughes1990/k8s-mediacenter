resource "cloudflare_record" "tautulli" {
  type    = "CNAME"
  zone_id = var.cloudflare_config.zone_id
  value   = var.cloudflare_config.zone_name
  name    = format("%s.%s", "metrics", cloudflare_record.plex.name)
}

module "tautulli" {
  depends_on = [kubernetes_namespace_v1.namespace]
  source     = "../../modules/deployment"
  name       = "tautulli"
  namespace  = kubernetes_namespace_v1.namespace.metadata[0].name
  image_url  = "linuxserver/tautulli"
  image_tag  = "latest"

  deployment_annotations = {
    "diun.enable" = true
  }

  ports = [
    {
      name           = "app-port"
      container_port = 8181
      is_ingress = {
        tls_cluster_issuer = local.tls_cluster_issuer
        additional_annotations = {
          "nginx.ingress.kubernetes.io/auth-url" = "https://${var.cloudflare_config.zone_name}/api/v2/auth/$1"
        }
        domains = [
          {
            name = cloudflare_record.tautulli.name
          }
        ]
      }
    }
  ]

  env = setunion(
    local.common_env,
    [
      # {
      #   name  = "DOCKER_MODS"
      #   value = "gilbn/theme.park:nzbget"
      # },
      # {
      #   name  = "TP_THEME"
      #   value = "plex"
      # },
    ]
  )

  host_directories = [
    {
      name       = "config"
      host_path  = format("%s/%s", var.directory_config.appdata, "tautulli")
      mount_path = "/config"
    },
  ]
}
