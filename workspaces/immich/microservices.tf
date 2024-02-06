module "microservices" {
  depends_on = [
    kubernetes_namespace_v1.namespace,
    module.postgres,
    module.server,
  ]
  source            = "../../modules/deployment"
  name              = local.deployment_names.microservices
  namespace         = kubernetes_namespace_v1.namespace.metadata[0].name
  image_url         = "ghcr.io/immich-app/immich-server"
  image_tag         = local.immich_version
  image_pull_policy = "Always"
  command           = ["/bin/sh"]
  args              = ["./start-microservices.sh"]

  ports = [
    {
      name           = "app-port"
      container_port = 3002
    }
  ]

  env = setunion(
    [
      {
        name  = "TZ"
        value = "America/Toronto"
      },
      {
        name  = "IMMICH_MACHINE_LEARNING_URL"
        value = "http://${local.deployment_names.machine_learning}-app-port.${kubernetes_namespace_v1.namespace.metadata[0].name}.svc:3003"
      },
    ],
    local.database_env,
    local.redis_env,
  )

  host_directories = [local.upload_host_directory]
}
