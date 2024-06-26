module "overseerr" {
  depends_on = [kubernetes_namespace_v1.namespace]
  source     = "../../modules/deployment"
  name       = "overseerr"
  namespace  = kubernetes_namespace_v1.namespace.metadata[0].name
  image_url  = "lscr.io/linuxserver/overseerr"
  image_tag  = "latest"
  replicas   = 0

  ports = [
    {
      name           = "app-port"
      container_port = 5055
      ingress = [
        {
          domain_match_pattern = "Host(`request.${var.cloudflare_config.zone_name}`)"
        },
      ]
    }
  ]

  env = local.common_env

  host_directories = [
    {
      name       = "config"
      host_path  = format("%s/%s", var.directory_config.appdata, "overseerr")
      mount_path = "/config"
    },
  ]
}
