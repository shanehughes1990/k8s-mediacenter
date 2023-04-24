module "ombi" {
  depends_on           = [kubernetes_namespace_v1.namespace]
  source               = "../../modules/deployment"
  name                 = "ombi"
  namespace            = kubernetes_namespace_v1.namespace.metadata[0].name
  image_url            = "lscr.io/linuxserver/ombi"
  image_tag            = "latest"
  metadata_annotations = local.keel_annotations

  ports = [
    {
      name           = "app-port"
      container_port = 3579
      ingress = [
        {
          domain_match_pattern = "Host(`${var.cloudflare_config.zone_name}`) && PathPrefix(`/ombi`)"
        },
      ]
    }
  ]

  env = setunion(
    local.common_env,
    [
      {
        name  = "BASE_URL"
        value = "/ombi"
      },
    ]
  )

  host_directories = [
    {
      name       = "config"
      host_path  = format("%s/%s", var.directory_config.appdata, "ombi")
      mount_path = "/config"
    },
  ]
}
