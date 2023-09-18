module "proxy" {
  depends_on = [
    kubernetes_namespace_v1.namespace,
    module.server
  ]
  source               = "../../modules/deployment"
  name                 = local.deployment_names.proxy
  namespace            = kubernetes_namespace_v1.namespace.metadata[0].name
  image_url            = "ghcr.io/immich-app/immich-proxy"
  image_tag            = local.immich_version
  image_pull_policy    = "Always"
  metadata_annotations = local.keel_annotations

  ports = [
    {
      name           = "app-port"
      container_port = 8080
      ingress = [
        {
          domain_match_pattern = "Host(`${local.public_server_url}`)"
        },
      ]
    }
  ]

  env = [
    {
      name  = "IMMICH_WEB_URL"
      value = "http://${local.deployment_names.web}-app-port.${kubernetes_namespace_v1.namespace.metadata[0].name}.svc:3000"
    },
    {
      name  = "IMMICH_SERVER_URL"
      value = "http://${local.deployment_names.server}-app-port.${kubernetes_namespace_v1.namespace.metadata[0].name}.svc:3001"
    },
  ]
}
