module "nzbget" {
  depends_on           = [kubernetes_namespace_v1.namespace]
  source               = "../../modules/deployment"
  name                 = "nzbget"
  namespace            = kubernetes_namespace_v1.namespace.metadata[0].name
  image_url            = "linuxserver/nzbget"
  image_tag            = "latest"
  metadata_annotations = local.keel_annotations

  ports = [
    {
      name           = "app-port"
      container_port = 6789
      # ingress = [
      #   {
      #     domain_match_pattern = "Host(`nzbget.${var.cloudflare_config.zone_name}`)"
      #     additional_annotations = {
      #       "nginx.ingress.kubernetes.io/auth-url" = "https://${data.terraform_remote_state.frontend.outputs.organizr.dns}/api/v2/auth/$1"
      #     }
      #   },
      # ]
    }
  ]

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
}
