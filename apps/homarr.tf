module "homarr" {
  depends_on           = [kubernetes_namespace_v1.namespace]
  source               = "../../modules/deployment"
  name                 = "homarr"
  namespace            = kubernetes_namespace_v1.namespace.metadata[0].name
  image_url            = "ghcr.io/ajnart/homarr"
  image_tag            = "latest"
  metadata_annotations = local.keel_annotations

  ports = [
    {
      name           = "app-port"
      container_port = 7575
      ingress = [
        {
          domain_match_pattern = "Host(`homarr.${var.cloudflare_config.zone_name}`)"
        },
      ]
    },
  ]

  # env = setunion(
  #   local.common_env,
  #   [
  #     {
  #       name  = "branch"
  #       value = "v2-master"
  #     },
  #     {
  #       name  = "fpm"
  #       value = false
  #     },
  #   ]
  # )

  host_directories = [
    {
      name       = "configs"
      host_path  = format("%s/%s/configs", var.directory_config.appdata, "homarr")
      mount_path = "/app/data/configs"
    },
    {
      name       = "icons"
      host_path  = format("%s/%s/icons", var.directory_config.appdata, "homarr")
      mount_path = "/app/public/icons"
    },
  ]
}
