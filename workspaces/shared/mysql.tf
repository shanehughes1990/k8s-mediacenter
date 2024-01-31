module "mysql" {
  depends_on           = [kubernetes_namespace_v1.namespace]
  source               = "../../modules/deployment"
  name                 = "mysql"
  namespace            = kubernetes_namespace_v1.namespace.metadata[0].name
  image_url            = "bitnami/mysql"
  image_tag            = "latest"
  metadata_annotations = local.keel_annotations

  ports = [
    {
      name           = "app-port"
      service_type   = "NodePort"
      container_port = 3306
      node_port      = 30003
    }
  ]

  env = [
    {
      name      = "MYSQL_ROOT_PASSWORD"
      value     = var.mysql_config.root_password
      is_secret = true
    },
    {
      name      = "MYSQL_USER"
      value     = var.mysql_config.username
      is_secret = true
    },
    {
      name      = "MYSQL_PASSWORD"
      value     = var.mysql_config.password
      is_secret = true
    },
  ]

  host_directories = [
    {
      name       = "data"
      host_path  = format("%s/%s", var.directory_config.appdata, "mysql")
      mount_path = "/bitnami/mysql/data"
    }
  ]
}
