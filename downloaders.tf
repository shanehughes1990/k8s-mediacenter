locals {
  nzbget = {
    name      = "nzbget"
    image_url = "linuxserver/nzbget"
    image_tag = "latest"
  }
}

module "nzbget" {
  depends_on = [kubernetes_namespace_v1.namespace]
  source     = "./modules/deployment"
  name       = local.nzbget.name
  namespace  = kubernetes_namespace_v1.namespace[local.namespaces[3]].metadata[0].name

  containers = [{
    name      = local.nzbget.name
    image_url = local.nzbget.image_url
    image_tag = local.nzbget.image_tag

    ports = [{
      name           = "http"
      container_port = 6789
    }]

    env = setunion(local.common_env)

    host_directories = [
      {
        name       = "config"
        host_path  = format("%s/%s", var.directory_config.appdata, local.nzbget.name)
        mount_path = "/config"
      },
      {
        name       = "tvshows"
        host_path  = var.directory_config.tv_shows
        mount_path = "/data/media/tvshows"
      },
      {
        name       = "downloads"
        host_path  = format("%s/usenet", var.directory_config.downloads)
        mount_path = "/data/downloads"
      },
    ]
  }]
}
