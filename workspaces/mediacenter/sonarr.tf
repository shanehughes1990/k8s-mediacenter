module "sonarr" {
  depends_on           = [kubernetes_namespace_v1.namespace]
  source               = "../../modules/deployment"
  name                 = "sonarr"
  namespace            = kubernetes_namespace_v1.namespace.metadata[0].name
  image_url            = "linuxserver/sonarr"
  image_tag            = "latest"
  image_pull_policy    = "Always"
  metadata_annotations = local.keel_annotations

  ports = [
    {
      name           = "app-port"
      container_port = 8989
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
      host_path  = format("%s/usenet", var.directory_config.downloads)
      mount_path = "/data/downloads"
    },
  ]
}

# module "sonarr_test" {
#   depends_on           = [kubernetes_namespace_v1.namespace]
#   source               = "../../modules/deployment"
#   name                 = "sonarr-test"
#   namespace            = kubernetes_namespace_v1.namespace.metadata[0].name
#   image_url            = "linuxserver/sonarr"
#   image_tag            = "develop"
#   image_pull_policy    = "Always"
#   metadata_annotations = local.keel_annotations

#   ports = [
#     {
#       name           = "app-port"
#       container_port = 8989
#       ingress = [
#         {
#           domains = [
#             {
#               name        = var.cloudflare_config.zone_name
#               domain_path = "/sonarr"
#             }
#           ]
#         },
#       ]
#     }
#   ]

#   env = setunion(
#     local.common_env,
#     [
#       {
#         name  = "DOCKER_MODS"
#         value = "gilbn/theme.park:sonarr"
#       },
#       {
#         name  = "TP_THEME"
#         value = "plex"
#       },
#     ]
#   )
# }
