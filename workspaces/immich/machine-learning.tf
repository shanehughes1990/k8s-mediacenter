module "machine_learning" {
  depends_on        = [kubernetes_namespace_v1.namespace]
  source            = "../../modules/deployment"
  name              = local.deployment_names.machine_learning
  namespace         = kubernetes_namespace_v1.namespace.metadata[0].name
  image_url         = "ghcr.io/immich-app/immich-machine-learning"
  image_tag         = local.immich_version
  image_pull_policy = "Always"

  ports = [
    {
      name           = "app-port"
      container_port = 3003
    }
  ]

  host_directories = [
    local.upload_host_directory,
    {
      name       = "cache"
      host_path  = format("%s/%s/%s", var.directory_config.appdata, local.environment, "cache")
      mount_path = "/cache"
    }
  ]
}
