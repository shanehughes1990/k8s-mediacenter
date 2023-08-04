module "petio" {
  depends_on           = [kubernetes_namespace_v1.namespace]
  source               = "../../modules/deployment"
  name                 = "petio"
  namespace            = kubernetes_namespace_v1.namespace.metadata[0].name
  image_url            = "ghcr.io/petio-team/petio"
  image_tag            = "latest"
  metadata_annotations = local.keel_annotations

  ports = [
    {
      name           = "app-port"
      container_port = 7777
      ingress = [
        {
          domain_match_pattern = "Host(`${var.cloudflare_config.zone_name}`) && PathPrefix(`/petio`)"
        },
      ]
    }
  ]

  env = local.common_env

  host_directories = [
    {
      name       = "config"
      host_path  = format("%s/%s", var.directory_config.appdata, "petio")
      mount_path = "/app/api/config"
    },
  ]
}
