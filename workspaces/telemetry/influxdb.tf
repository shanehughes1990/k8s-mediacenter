module "influxdb" {
  depends_on           = [kubernetes_namespace_v1.namespace]
  source               = "../../modules/deployment"
  name                 = "influxdb"
  namespace            = kubernetes_namespace_v1.namespace.metadata[0].name
  image_url            = "influxdb"
  image_tag            = "latest"
  metadata_annotations = local.keel_annotations
  ports = [
    {
      name           = "app-port"
      container_port = 8086
    }
  ]

  env = [
    {
      name  = "DOCKER_INFLUXDB_INIT_MODE"
      value = "setup"
    },
    {
      name      = "DOCKER_INFLUXDB_INIT_USERNAME"
      value     = var.influxdb_config.username
      is_secret = true
    },
    {
      name      = "DOCKER_INFLUXDB_INIT_PASSWORD"
      value     = var.influxdb_config.password
      is_secret = true
    },
    {
      name      = "DOCKER_INFLUXDB_INIT_ORG"
      value     = var.influxdb_config.org
      is_secret = true
    },
    {
      name      = "DOCKER_INFLUXDB_INIT_BUCKET"
      value     = var.influxdb_config.bucket
      is_secret = true
    },
  ]

  host_directories = [
    {
      name       = "data"
      host_path  = format("%s/%s", var.directory_config.appdata, "influxdb")
      mount_path = "/var/lib/influxdb2"
    }
  ]
}
