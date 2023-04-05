module "postgres" {
  depends_on           = [kubernetes_namespace_v1.namespace]
  source               = "../../modules/deployment"
  name                 = "postgres"
  namespace            = kubernetes_namespace_v1.namespace.metadata[0].name
  image_url            = "postgres"
  image_tag            = "12.3"
  metadata_annotations = local.keel_annotations

  ports = [
    {
      name           = "sql-port"
      container_port = 5432
    }
  ]

  env = [
    {
      name  = "POSTGRES_USER"
      value = var.postgres_config.username
    },
    {
      name      = "POSTGRES_PASSWORD"
      value     = var.postgres_config.password
      is_secret = true
    },
  ]

  host_directories = [
    {
      name       = "config"
      mount_path = "/var/lib/postgresql/data"
      host_path  = format("%s/%s", var.directory_config.appdata, "postgres")
    }
  ]
}
