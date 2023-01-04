module "tautulli" {
  depends_on = [kubernetes_namespace_v1.namespace]
  source     = "../../modules/deployment"
  name       = "tautulli"
  namespace  = kubernetes_namespace_v1.namespace.metadata[0].name

  containers = [{
    name      = "tautulli"
    image_url = "linuxserver/tautulli"
    image_tag = "latest"

    ports = [{
      name           = "http"
      container_port = 8181
    }]

    env = setunion(
      local.common_env,
      [
        # {
        #   name  = "DOCKER_MODS"
        #   value = "gilbn/theme.park:nzbget"
        # },
        # {
        #   name  = "TP_THEME"
        #   value = "plex"
        # },
      ]
    )

    host_directories = [
      {
        name       = "config"
        host_path  = format("%s/%s", var.directory_config.appdata, "tautulli")
        mount_path = "/config"
      },
    ]
  }]
}
