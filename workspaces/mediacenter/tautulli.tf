module "tautulli" {
  depends_on           = [kubernetes_namespace_v1.namespace]
  source               = "../../modules/deployment"
  name                 = "tautulli"
  namespace            = kubernetes_namespace_v1.namespace.metadata[0].name
  image_url            = "linuxserver/tautulli"
  image_tag            = "latest"
  metadata_annotations = local.keel_annotations
  replicas             = 0

  ports = [
    {
      name           = "app-port"
      container_port = 8181
      ingress = [
        {
          domain_match_pattern = "Host(`${var.cloudflare_config.zone_name}`) && PathPrefix(`/tautulli`)"
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
  )

  host_directories = [
    {
      name       = "config"
      host_path  = format("%s/%s", var.directory_config.appdata, "tautulli")
      mount_path = "/config"
    },
  ]
}
