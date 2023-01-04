module "overseerr" {
  depends_on = [kubernetes_namespace_v1.namespace]
  source     = "../../modules/deployment"
  name       = "overseerr"
  namespace  = kubernetes_namespace_v1.namespace.metadata[0].name

  containers = [{
    name      = "overseerr"
    image_url = "linuxserver/overseerr"
    image_tag = "latest"

    ports = [{
      name           = "http"
      container_port = 5055
    }]

    env = setunion(
      local.common_env,
      [
        {
          name  = "DOCKER_MODS"
          value = "gilbn/theme.park:overseerr"
        },
        {
          name  = "TP_THEME"
          value = "plex"
        },
      ]
    )

    host_directories = [
      {
        name       = "config"
        host_path  = format("%s/%s", var.directory_config.appdata, "overseerr")
        mount_path = "/config"
      },
    ]
  }]
}
