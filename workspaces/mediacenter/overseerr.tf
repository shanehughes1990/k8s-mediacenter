resource "cloudflare_record" "overseerr" {
  type    = "CNAME"
  zone_id = var.cloudflare_config.zone_id
  value   = var.cloudflare_config.zone_name
  name    = format("%s.%s", "request", cloudflare_record.plex.name)
}

module "overseerr" {
  depends_on = [kubernetes_namespace_v1.namespace]
  source     = "../../modules/deployment"
  name       = "overseerr"
  namespace  = kubernetes_namespace_v1.namespace.metadata[0].name
  image_url  = "linuxserver/overseerr"
  image_tag  = "latest"

  ports = [
    {
      name           = "app-port"
      container_port = 5055
      is_ingress = {
        tls_cluster_issuer = local.tls_cluster_issuer
        domains = [
          {
            name = cloudflare_record.overseerr.name
          },
        ]
      }
    }
  ]

  env = setunion(
    local.common_env,
    [
      {
        name  = "DOCKER_MODS"
        value = "gilbn/theme.park:overseerr"
      },
      {
        name  = "TP_THEME"
        value = "plex"
      },
    ]
  )

  host_directories = [
    {
      name       = "config"
      host_path  = format("%s/%s", var.directory_config.appdata, "overseerr")
      mount_path = "/config"
    },
  ]
}
