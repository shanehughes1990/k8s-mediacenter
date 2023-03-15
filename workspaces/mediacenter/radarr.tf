resource "cloudflare_record" "radarr" {
  type    = "CNAME"
  zone_id = var.cloudflare_config.zone_id
  value   = var.cloudflare_config.zone_name
  name    = format("%s.%s", "movies", cloudflare_record.plex.name)
}

resource "cloudflare_record" "radarr_basic_auth" {
  type    = "CNAME"
  zone_id = var.cloudflare_config.zone_id
  value   = var.cloudflare_config.zone_name
  name    = format("%s.%s", "movies", cloudflare_record.basic_auth.name)
}

module "radarr" {
  depends_on = [kubernetes_namespace_v1.namespace]
  source     = "../../modules/deployment"
  name       = "radarr"
  namespace  = kubernetes_namespace_v1.namespace.metadata[0].name
  image_url  = "linuxserver/radarr"
  image_tag  = "develop"

  deployment_annotations = {
    "diun.enable" = true
  }

  ports = [
    {
      name           = "app-port"
      container_port = 7878
      ingress = [
        {
          tls_cluster_issuer = local.tls_cluster_issuer
          additional_annotations = {
            "nginx.ingress.kubernetes.io/auth-url" = "https://${var.cloudflare_config.zone_name}/api/v2/auth/$1"
          }
          domains = [
            {
              name = cloudflare_record.radarr.name
            }
          ]
        },
        {
          tls_cluster_issuer     = local.tls_cluster_issuer
          additional_annotations = local.basic_auth_annotations
          domains = [
            {
              name = cloudflare_record.radarr_basic_auth.name
            },
          ]
        },
      ]
    }
  ]

  env = setunion(
    local.common_env,
    [
      {
        name  = "DOCKER_MODS"
        value = "gilbn/theme.park:radarr"
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
      host_path  = format("%s/%s", var.directory_config.appdata, "radarr")
      mount_path = "/config"
    },
    {
      name       = "movies"
      host_path  = var.directory_config.movies
      mount_path = "/data/media/movies"
    },
    {
      name       = "downloads"
      host_path  = format("%s/usenet", var.directory_config.downloads)
      mount_path = "/data/downloads"
    },
  ]
}
