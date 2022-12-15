locals {
  overseerr = {
    name      = "overseerr"
    image_url = "linuxserver/overseerr"
    image_tag = "latest"
  }

  tautulli = {
    name      = "tautulli"
    image_url = "linuxserver/tautulli"
    image_tag = "latest"
  }
}

module "overseerr" {
  depends_on = [kubernetes_namespace_v1.namespace]
  source     = "./modules/deployment"
  name       = local.overseerr.name
  namespace  = kubernetes_namespace_v1.namespace[local.namespaces[3]].metadata[0].name

  containers = [{
    name      = local.overseerr.name
    image_url = local.overseerr.image_url
    image_tag = local.overseerr.image_tag

    ports = [{
      name           = "http"
      container_port = 5055
    }]

    env = setunion(local.common_env)

    host_directories = [
      {
        name       = "config"
        host_path  = format("%s/%s", var.directory_config.appdata, local.overseerr.name)
        mount_path = "/config"
      }
    ]
  }]
}

module "tautulli" {
  depends_on = [kubernetes_namespace_v1.namespace]
  source     = "./modules/deployment"
  name       = local.tautulli.name
  namespace  = kubernetes_namespace_v1.namespace[local.namespaces[3]].metadata[0].name

  containers = [{
    name      = local.tautulli.name
    image_url = local.tautulli.image_url
    image_tag = local.tautulli.image_tag

    ports = [{
      name           = "http"
      container_port = 8181
    }]

    env = setunion(local.common_env)

    host_directories = [
      {
        name       = "config"
        host_path  = format("%s/%s", var.directory_config.appdata, local.tautulli.name)
        mount_path = "/config"
      }
    ]
  }]
}
