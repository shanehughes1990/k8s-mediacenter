module "mongo" {
  depends_on           = [kubernetes_namespace_v1.namespace]
  source               = "../../modules/deployment"
  name                 = "mongo"
  namespace            = kubernetes_namespace_v1.namespace.metadata[0].name
  image_url            = "mongo"
  image_tag            = "latest"
  metadata_annotations = local.keel_annotations

  ports = [
    {
      name           = "mongo-port"
      container_port = 27017
    }
  ]

  env = [
    {
      name  = "MONGO_INITDB_ROOT_USERNAME"
      value = var.mongo_config.root_username
    },
    {
      name      = "MONGO_INITDB_ROOT_PASSWORD"
      value     = var.mongo_config.root_password
      is_secret = true
    },
  ]

  host_directories = [
    {
      name       = "config"
      mount_path = "/data/db"
      host_path  = format("%s/%s", var.directory_config.appdata, "mongo")
    }
  ]
}
