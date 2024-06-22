module "sabnzbd" {
  depends_on = [kubernetes_namespace_v1.namespace]
  source     = "../../modules/deployment"
  name       = "sabnzbd"
  namespace  = kubernetes_namespace_v1.namespace.metadata[0].name
  image_url  = "lscr.io/linuxserver/sabnzbd"
  image_tag  = "latest"

  ports = [
    {
      name           = "app-port"
      container_port = 8080
      ingress = [
        {
          domain_match_pattern = "Host(`${var.cloudflare_config.zone_name}`) && PathPrefix(`/sabnzbd`)"
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

  env = setunion(
    local.common_env,
    [
      {
        name  = "DOCKER_MODS"
        value = "gilbn/theme.park:sabnzbd"
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
      host_path  = format("%s/%s", var.directory_config.appdata, "sabnzbd")
      mount_path = "/config"
    },
    {
      name       = "downloads"
      host_path  = format("%s/sabnzbd", var.directory_config.downloads)
      mount_path = "/data/downloads"
    },
  ]
}
