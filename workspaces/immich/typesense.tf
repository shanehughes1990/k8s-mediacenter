module "typesense" {
  depends_on           = [kubernetes_namespace_v1.namespace]
  source               = "../../modules/deployment"
  name                 = "typesense"
  namespace            = kubernetes_namespace_v1.namespace.metadata[0].name
  image_url            = "typesense/typesense"
  image_tag            = "0.25.1"
  metadata_annotations = local.keel_annotations

  ports = [
    {
      name           = "app-port"
      container_port = 8108
    }
  ]

  env = [
    {
      name  = "TYPESENSE_DATA_DIR"
      value = "/data"
    },
    {
      name      = "TYPESENSE_API_KEY"
      value     = var.typesense_api_key
      is_secret = true
    },
  ]

  host_directories = [
    {
      name       = "data"
      host_path  = format("%s/%s/%s", var.directory_config.appdata, local.environment, "typesense")
      mount_path = "/data"
    },
  ]
}
