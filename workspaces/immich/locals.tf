locals {
  keel_annotations = {
    "keel.sh/policy"       = "force"
    "keel.sh/pollSchedule" = "@every 10m"
    "keel.sh/trigger"      = "poll"
  }

  immich_version    = "v1.94.1"
  public_server_url = "photos.${var.cloudflare_config.zone_name}"

  deployment_names = {
    server           = "server"
    microservices    = "microservices"
    web              = "web"
    proxy            = "proxy"
    machine_learning = "machine-learning"
    database         = "postgres"
    redis            = "redis"
    typesense        = "typesense"
  }

  database_env = [
    {
      name  = "DB_HOSTNAME"
      value = "${local.deployment_names.database}-app-port.${kubernetes_namespace_v1.namespace.metadata[0].name}.svc"
    },
    {
      name  = "DB_PORT"
      value = 5432
    },
    {
      name  = "DB_USERNAME"
      value = var.postgres_config.username
    },
    {
      name      = "DB_PASSWORD"
      value     = var.postgres_config.password
      is_secret = true
    },
    {
      name  = "DB_DATABASE"
      value = var.postgres_config.username
    },
    {
      name  = "DB_DATABASE_NAME"
      value = var.postgres_config.username
    },
  ]

  redis_env = [
    {
      name  = "REDIS_HOSTNAME"
      value = "${local.deployment_names.redis}-app-port.${kubernetes_namespace_v1.namespace.metadata[0].name}.svc"
    },
    {
      name  = "REDIS_PORT"
      value = 6379
    },
    {
      name  = "REDIS_DBINDEX"
      value = 0
    },
  ]

  upload_host_directory = {
    name       = "upload"
    host_path  = "/local_media/immich"
    mount_path = "/usr/src/app/upload"
  }
}
