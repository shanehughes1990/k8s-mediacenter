module "nzbget" {
  depends_on = [kubernetes_namespace_v1.namespace]
  source     = "../../modules/deployment"
  name       = "nzbget"
  namespace  = kubernetes_namespace_v1.namespace.metadata[0].name

  containers = [{
    name      = "nzbget"
    image_url = "linuxserver/nzbget"
    image_tag = "latest"

    ports = [{
      name           = "http"
      container_port = 6789
    }]

    env = setunion(
      local.common_env,
      [
        {
          name  = "DOCKER_MODS"
          value = "gilbn/theme.park:nzbget"
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
        host_path  = format("%s/%s", var.directory_config.appdata, "nzbget")
        mount_path = "/config"
      },
      {
        name       = "downloads"
        host_path  = format("%s/usenet", var.directory_config.downloads)
        mount_path = "/data/downloads"
      },
    ]
  }]
}
