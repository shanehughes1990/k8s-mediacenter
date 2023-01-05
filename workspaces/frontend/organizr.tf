resource "cloudflare_record" "organizr" {
  type    = "CNAME"
  zone_id = var.cloudflare_config.zone_id
  value   = var.cloudflare_config.zone_name
  name    = format("%s.%s", "web", var.cloudflare_config.zone_name)
}

module "organizr" {
  depends_on = [kubernetes_namespace_v1.namespace]
  source     = "../../modules/deployment"
  name       = "organizr"
  namespace  = kubernetes_namespace_v1.namespace.metadata[0].name
  image_url  = "organizr/organizr"
  image_tag  = "latest"

  ports = [
    {
      name           = "app-port"
      container_port = 80
      is_ingress = {
        tls_cluster_issuer = local.tls_cluster_issuer
        domains = [
          {
            name = var.cloudflare_config.zone_name
          },
          {
            name = cloudflare_record.organizr.name
          },
        ]
      }
    },
  ]

  env = setunion(
    local.common_env,
    [
      {
        name  = "branch"
        value = "v2-develop"
      },
      {
        name  = "fpm"
        value = false
      },
    ]
  )

  host_directories = [
    {
      name       = "config"
      host_path  = format("%s/%s", var.directory_config.appdata, "organizr")
      mount_path = "/config"
    }
  ]
}
