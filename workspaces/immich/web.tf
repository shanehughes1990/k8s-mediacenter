module "web" {
  depends_on           = [kubernetes_namespace_v1.namespace]
  source               = "../../modules/deployment"
  name                 = local.deployment_names.web
  namespace            = kubernetes_namespace_v1.namespace.metadata[0].name
  image_url            = "ghcr.io/immich-app/immich-web"
  image_tag            = local.immich_version
  metadata_annotations = local.keel_annotations
  command              = ["/bin/sh"]
  args                 = ["./entrypoint.sh"]

  ports = [
    {
      name           = "app-port"
      container_port = 3000
    }
  ]

  env = [
    {
      name  = "PUBLIC_LOGIN_PAGE_MESSAGE"
      value = "Tecsharp Photos"
    },
    {
      name  = "IMMICH_SERVER_URL"
      value = "http://${local.deployment_names.server}-app-port.${kubernetes_namespace_v1.namespace.metadata[0].name}.svc:3001"
    },
    {
      name  = "PUBLIC_IMMICH_SERVER_URL"
      value = "https://${local.public_server_url}"
    },
  ]
}
