module "organizr" {
  depends_on = [kubernetes_namespace_v1.namespace]
  source     = "../../modules/deployment"
  name       = "organizr"
  namespace  = kubernetes_namespace_v1.namespace.metadata[0].name

  containers = [{
    name      = "organizr"
    image_url = "organizr/organizr"
    image_tag = "latest"

    ports = [{
      name           = "http"
      container_port = 80
    }]

    env = setunion(
      local.common_env,
      [
        {
          name  = "branch"
          value = "v2-develop"
        },
        {
          name  = "fpm"
          value = false
        },
      ]
    )

    host_directories = [
      {
        name       = "config"
        host_path  = format("%s/%s", var.directory_config.appdata, "organizr")
        mount_path = "/config"
      }
    ]
  }]
}
