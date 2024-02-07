module "mariadb" {
  depends_on           = [kubernetes_namespace_v1.namespace]
  source               = "../../modules/deployment"
  name                 = "mariadb"
  namespace            = kubernetes_namespace_v1.namespace.metadata[0].name
  image_url            = "bitnami/mariadb"
  image_tag            = "latest"
  metadata_annotations = local.keel_annotations

  ports = [
    {
      name           = "app-port"
      service_type   = "NodePort"
      container_port = 3306
      node_port      = 30005
    }
  ]

  env = [
    {
      name      = "MARIADB_ROOT_PASSWORD"
      value     = var.mariadb_config.root_password
      is_secret = true
    },
    {
      name      = "MARIADB_USER"
      value     = var.mariadb_config.username
      is_secret = true
    },
    {
      name      = "MARIADB_PASSWORD"
      value     = var.mariadb_config.password
      is_secret = true
    },
  ]

  host_directories = [
    {
      name       = "data"
      host_path  = format("%s/%s", var.directory_config.appdata, "mariadb")
      mount_path = "/bitnami/mariadb"
    }
  ]
}
