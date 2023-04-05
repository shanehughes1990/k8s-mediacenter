resource "cloudflare_record" "nzbget" {
  type    = "CNAME"
  zone_id = var.cloudflare_config.zone_id
  value   = var.cloudflare_config.zone_name
  name    = format("%s.%s", "usenet", cloudflare_record.plex.name)
}

resource "cloudflare_record" "nzbget_basic_auth" {
  type    = "CNAME"
  zone_id = var.cloudflare_config.zone_id
  value   = var.cloudflare_config.zone_name
  name    = format("%s.%s", "usenet", cloudflare_record.basic_auth.name)
}

module "nzbget" {
  depends_on           = [kubernetes_namespace_v1.namespace]
  source               = "../../modules/deployment"
  name                 = "nzbget"
  namespace            = kubernetes_namespace_v1.namespace.metadata[0].name
  image_url            = "linuxserver/nzbget"
  image_tag            = "latest"
  metadata_annotations = local.keel_annotations

  ports = [
    {
      name           = "app-port"
      container_port = 6789
      ingress = [
        {
          tls_cluster_issuer = local.tls_cluster_issuer
          additional_annotations = {
            "nginx.ingress.kubernetes.io/auth-url" = "https://${data.terraform_remote_state.frontend.outputs.organizr.dns}/api/v2/auth/$1"
          }
          domains = [
            {
              name = cloudflare_record.nzbget.name
            },
          ]
        },
        {
          tls_cluster_issuer     = local.tls_cluster_issuer
          additional_annotations = local.basic_auth_annotations
          domains = [
            {
              name = cloudflare_record.nzbget_basic_auth.name
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
