module "sonarr" {
  depends_on = [kubernetes_namespace_v1.namespace]
  source     = "../../modules/deployment"
  name       = "sonarr"
  namespace  = kubernetes_namespace_v1.namespace.metadata[0].name

  containers = [{
    name      = "sonarr"
    image_url = "linuxserver/sonarr"
    image_tag = "develop"

    ports = [{
      name           = "http"
      container_port = 8989
    }]

    env = setunion(
      local.common_env,
      [
        {
          name  = "DOCKER_MODS"
          value = "gilbn/theme.park:sonarr"
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
        host_path  = format("%s/%s", var.directory_config.appdata, "sonarr")
        mount_path = "/config"
      },
      {
        name       = "tvshows"
        host_path  = var.directory_config.tv_shows
        mount_path = "/data/media/tvshows"
      },
      {
        name       = "downloads"
        host_path  = var.directory_config.downloads
        mount_path = "/data/downloads"
      },
    ]
  }]
}
