module "pgadmin" {
  depends_on           = [kubernetes_namespace_v1.namespace]
  source               = "../../modules/deployment"
  name                 = "pgadmin"
  namespace            = kubernetes_namespace_v1.namespace.metadata[0].name
  image_url            = "dpage/pgadmin4"
  image_tag            = "latest"
  metadata_annotations = local.keel_annotations

  ports = [
    {
      name           = "app-port"
      container_port = 80
      ingress = [
        {
          domain_match_pattern = "Host(`pgadmin.${var.cloudflare_config.zone_name}`)"
        },
      ]
    }
  ]

  env = [
    {
      name  = "PGADMIN_DEFAULT_EMAIL"
      value = var.cloudflare_config.email
    },
    {
      name      = "PGADMIN_DEFAULT_PASSWORD"
      value     = var.pgadmin_password
      is_secret = true
    },
  ]

  host_directories = [
    {
      name       = "config"
      mount_path = "/var/lib/pgadmin"
      host_path  = format("%s/%s", var.directory_config.appdata, "pgadmin")
    }
  ]
}
