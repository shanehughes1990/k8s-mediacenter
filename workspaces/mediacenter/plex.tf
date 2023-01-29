resource "cloudflare_record" "plex" {
  type    = "CNAME"
  zone_id = var.cloudflare_config.zone_id
  value   = var.cloudflare_config.zone_name
  name    = format("%s.%s", "media", var.cloudflare_config.zone_name)
}

module "plex" {
  depends_on = [kubernetes_namespace_v1.namespace]
  source     = "../../modules/deployment"
  name       = "plex"
  namespace  = kubernetes_namespace_v1.namespace.metadata[0].name
  image_url  = "linuxserver/plex"
  image_tag  = "latest"

  deployment_annotations = {
    "diun.enable" = true
  }

  ports = [
    {
      name           = "app-port"
      service_type   = "NodePort"
      container_port = 32400
      node_port      = 32400
    }
  ]

  // TODO: Fix gpu operator
  # resources = {
  #   limits = {
  #     gpu = 1
  #   }
  # }

  env = setunion(
    local.common_env,
    [
      {
        name  = "VERSION"
        value = "docker"
      },
      {
        name  = "NVIDIA_VISIBLE_DEVICES"
        value = "all"
      },
      {
        name      = "PLEX_CLAIM"
        value     = var.plex_claim
        is_secret = true
      },
    ]
  )

  host_directories = [
    {
      name       = "config"
      host_path  = format("%s/%s", var.directory_config.appdata, "plex")
      mount_path = "/config"
    },
    {
      name       = "media"
      host_path  = var.directory_config.media
      mount_path = "/data/media"
    },
    {
      name       = "transcoding"
      host_path  = format("%s/plex", var.directory_config.transcoding)
      mount_path = "/transcoding"
    },
  ]
}
