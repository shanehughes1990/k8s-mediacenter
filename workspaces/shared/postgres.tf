module "postgres" {
  depends_on = [kubernetes_namespace_v1.namespace]
  source     = "../../modules/deployment"
  name       = "postgresql"
  namespace  = kubernetes_namespace_v1.namespace.metadata[0].name
  image_url  = "bitnami/postgresql"
  image_tag  = "latest"

  ports = [
    {
      name           = "app-port"
      service_type   = "NodePort"
      container_port = 5432
      node_port      = 30006
    }
  ]

  env = [
    {
      name      = "POSTGRESQL_PASSWORD"
      value     = var.postgresql_config.root_password
      is_secret = true
    },
  ]

  host_directories = [
    {
      name       = "data"
      host_path  = format("%s/%s", var.directory_config.appdata, "postgresql")
      mount_path = "/bitnami/postgresql"
    }
  ]
}
