resource "cloudflare_record" "jellyfin" {
  type    = "CNAME"
  zone_id = var.cloudflare_config.zone_id
  value   = var.cloudflare_config.zone_name
  name    = format("%s.%s", "jellyfin", var.cloudflare_config.zone_name)
}

module "jellyfin" {
  depends_on = [kubernetes_namespace_v1.namespace]
  source     = "../../modules/deployment"
  name       = "jellyfin"
  namespace  = kubernetes_namespace_v1.namespace.metadata[0].name
  image_url  = "linuxserver/jellyfin"
  image_tag  = "latest"

  deployment_annotations = {
    "diun.enable" = true
  }

  ports = [
    {
      name           = "app-port"
      container_port = 8096
      ingress = [
        {
          tls_cluster_issuer = local.tls_cluster_issuer
          domains = [
            {
              name = cloudflare_record.jellyfin.name
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
        name  = "NVIDIA_VISIBLE_DEVICES"
        value = "all"
      },
      {
        name  = "NVIDIA_DRIVER_CAPABILITIES"
        value = "compute,video,utility"
      },
    ]
  )

  host_directories = [
    {
      name       = "config"
      host_path  = format("%s/%s", var.directory_config.appdata, "jellyfin")
      mount_path = "/config"
    },
    {
      name       = "media"
      host_path  = var.directory_config.media
      mount_path = "/data/media"
    },
  ]

  # ram_disks = [
  #   {
  #     name       = "transcoding"
  #     mount_path = "/transcoding"
  #   }
  # ]
}
