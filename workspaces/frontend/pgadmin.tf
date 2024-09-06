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
          middlewares = [
            {
              name      = kubernetes_manifest.organizr_forward_auth_admin.manifest.metadata.name
              namespace = kubernetes_manifest.organizr_forward_auth_admin.manifest.metadata.namespace
            }
          ]
        },
      ]
    },
  ]

  env = [
    {
      name  = "PGADMIN_DEFAULT_EMAIL"
      value = var.pgadmin_config.email
    },
    {
      name      = "PGADMIN_DEFAULT_PASSWORD"
      value     = var.pgadmin_config.password
      is_secret = true
    },
  ]

  host_directories = [
    {
      name       = "data"
      host_path  = format("%s/%s", var.directory_config.appdata, "pgadmin")
      mount_path = "/var/lib/pgadmin"
    }
  ]
}
