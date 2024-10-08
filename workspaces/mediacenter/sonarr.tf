module "sonarr" {
  depends_on           = [kubernetes_namespace_v1.namespace]
  source               = "../../modules/deployment"
  name                 = "sonarr"
  namespace            = kubernetes_namespace_v1.namespace.metadata[0].name
  image_url            = "linuxserver/sonarr"
  image_tag            = "latest"
  metadata_annotations = local.keel_annotations

  pod_security_context = {
    fs_group = 1000
  }

  ports = [
    {
      name           = "app-port"
      container_port = 8989
      service_type   = "NodePort"
      node_port      = 32767
      ingress = [
        {
          domain_match_pattern = "Host(`${var.cloudflare_config.zone_name}`) && PathPrefix(`/sonarr`)"
          middlewares = [
            {
              name      = data.terraform_remote_state.frontend.outputs.organizr.middlewares.auth_admin.name
              namespace = data.terraform_remote_state.frontend.outputs.organizr.middlewares.auth_admin.namespace
            }
          ]
        },
      ]
    }
  ]

  env = concat(
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
    # {
    #   name       = "anime"
    #   host_path  = var.directory_config.anime
    #   mount_path = var.directory_config.anime
    # },
    {
      name       = "sabnzbd"
      host_path  = format("%s/sabnzbd", var.directory_config.downloads)
      mount_path = "/data/downloads"
    },
  ]
}
