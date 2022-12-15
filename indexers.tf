locals {
  sonarr = {
    name      = "sonarr"
    image_url = "linuxserver/sonarr"
    image_tag = "develop"
  }
  radarr = {
    name      = "radarr"
    image_url = "linuxserver/radarr"
    image_tag = "develop"
  }
}

module "sonarr" {
  depends_on = [kubernetes_namespace_v1.namespace]
  source     = "./modules/deployment"
  name       = local.sonarr.name
  namespace  = kubernetes_namespace_v1.namespace[local.namespaces[3]].metadata[0].name

  containers = [{
    name      = local.sonarr.name
    image_url = local.sonarr.image_url
    image_tag = local.sonarr.image_tag

    ports = [{
      name           = "http"
      container_port = 8989
    }]

    env = setunion(local.common_env)

    host_directories = [
      {
        name       = "config"
        host_path  = format("%s/%s", var.directory_config.appdata, local.sonarr.name)
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

module "radarr" {
  depends_on = [kubernetes_namespace_v1.namespace]
  source     = "./modules/deployment"
  name       = local.radarr.name
  namespace  = kubernetes_namespace_v1.namespace[local.namespaces[3]].metadata[0].name

  containers = [{
    name      = local.radarr.name
    image_url = local.radarr.image_url
    image_tag = local.radarr.image_tag

    ports = [{
      name           = "http"
      container_port = 7878
    }]

    env = setunion(local.common_env)

    host_directories = [
      {
        name       = "config"
        host_path  = format("%s/%s", var.directory_config.appdata, local.radarr.name)
        mount_path = "/config"
      },
      {
        name       = "movies"
        host_path  = var.directory_config.movies
        mount_path = "/data/media/movies"
      },
      {
        name       = "downloads"
        host_path  = var.directory_config.downloads
        mount_path = "/data/downloads"
      },
    ]
  }]
}
