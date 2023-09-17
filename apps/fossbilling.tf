module "fossbilling" {
  depends_on = [kubernetes_namespace_v1.namespace]
  source     = "../../modules/deployment"
  name       = "fossbilling"
  namespace  = kubernetes_namespace_v1.namespace.metadata[0].name
  image_url  = "fossbilling/fossbilling"
  image_tag  = "latest"

  ports = [
    {
      name           = "app-port"
      container_port = 80
      ingress = [
        {
          domain_match_pattern = "Host(`billing.${var.cloudflare_config.zone_name}`)"
        },
      ]
    },
  ]

  host_directories = [
    {
      name       = "config"
      host_path  = format("%s/%s", var.directory_config.appdata, "fossbilling")
      mount_path = "/var/www/html"
    }
  ]
}
