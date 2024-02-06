module "postgres" {
  depends_on = [kubernetes_namespace_v1.namespace]
  source     = "../../modules/deployment"
  name       = local.deployment_names.database
  namespace  = kubernetes_namespace_v1.namespace.metadata[0].name
  image_url  = "tensorchord/pgvecto-rs"
  image_tag  = "pg14-v0.1.11@sha256:0335a1a22f8c5dd1b697f14f079934f5152eaaa216c09b61e293be285491f8ee"

  ports = [
    {
      name           = "app-port"
      container_port = 5432
    }
  ]

  env = [
    {
      name  = "POSTGRES_USER"
      value = var.postgres_config.username
    },
    {
      name  = "POSTGRES_DB"
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
      host_path  = format("%s/%s/%s", var.directory_config.appdata, local.environment, "postgres")
    }
  ]
}
