module "dbeaver" {
  depends_on           = [kubernetes_namespace_v1.namespace]
  source               = "../../modules/deployment"
  name                 = "dbeaver"
  namespace            = kubernetes_namespace_v1.namespace.metadata[0].name
  image_url            = "dbeaver/cloudbeaver"
  image_tag            = "latest"
  metadata_annotations = local.keel_annotations

  ports = [
    {
      name           = "app-port"
      container_port = 8978
      ingress = [
        {
          domain_match_pattern = "Host(`dbeaver.${var.cloudflare_config.zone_name}`)"
        },
      ]
    },
  ]

  host_directories = [
    {
      name       = "data"
      host_path  = format("%s/%s", var.directory_config.appdata, "dbeaver")
      mount_path = "/opt/cloudbeaver/workspace"
    }
  ]
}
