resource "cloudflare_record" "nzbget" {
  type    = "CNAME"
  zone_id = var.cloudflare_config.zone_id
  value   = var.cloudflare_config.zone_name
  name    = format("%s.%s", "usenet", var.cloudflare_config.zone_name)
}

module "nzbget" {
  depends_on = [kubernetes_namespace_v1.namespace]
  source     = "../../modules/deployment"
  name       = "nzbget"
  namespace  = kubernetes_namespace_v1.namespace.metadata[0].name
  image_url  = "linuxserver/nzbget"
  image_tag  = "latest"

  ports = [
    {
      name           = "app-port"
      container_port = 6789
      # is_ingress = {
      #   tls_cluster_issuer = local.tls_cluster_issuer
      #   domains = [
      #     {
      #       name = cloudflare_record.nzbget.name
      #     }
      #   ]
      # }
    }
  ]

  env = setunion(
    local.common_env,
    [
      {
        name  = "DOCKER_MODS"
        value = "gilbn/theme.park:nzbget"
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
      host_path  = format("%s/%s", var.directory_config.appdata, "nzbget")
      mount_path = "/config"
    },
    {
      name       = "downloads"
      host_path  = format("%s/usenet", var.directory_config.downloads)
      mount_path = "/data/downloads"
    },
  ]
}
