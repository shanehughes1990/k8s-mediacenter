module "plex" {
  depends_on = [kubernetes_namespace_v1.namespace]
  source     = "../../modules/deployment"
  name       = "plex"
  namespace  = kubernetes_namespace_v1.namespace.metadata[0].name

  containers = [{
    name      = "plex"
    image_url = "linuxserver/plex"
    image_tag = "latest"

    ports = [
      {
        name           = "app-port"
        container_port = 32400
        service_type   = "NodePort"
        node_port      = 32400
      }
    ]

    // TODO: Fix gpu operator
    # resources = {
    #   limits = {
    #     gpu = 1
    #   }
    # }

    env = setunion(
      local.common_env,
      [
        {
          name  = "VERSION"
          value = "docker"
        },
        {
          name  = "NVIDIA_VISIBLE_DEVICES"
          value = "all"
        },
      ]
    )

    env_secrets = [
      {
        name  = "PLEX_CLAIM"
        value = var.plex_claim
      }
    ]

    host_directories = [
      {
        name       = "config"
        host_path  = format("%s/%s", var.directory_config.appdata, "plex")
        mount_path = "/config"
      },
      {
        name       = "media"
        host_path  = var.directory_config.media
        mount_path = "/data/media"
      },
      {
        name       = "transcoding"
        host_path  = format("%s/plex", var.directory_config.transcoding)
        mount_path = "/transcoding"
      },
    ]
  }]
}
