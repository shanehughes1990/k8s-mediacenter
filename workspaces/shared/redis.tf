module "redis" {
  depends_on = [kubernetes_namespace_v1.namespace]
  source     = "../../modules/deployment"
  name       = "redis"
  namespace  = kubernetes_namespace_v1.namespace.metadata[0].name
  image_url  = "bitnami/redis"
  image_tag  = "latest"

  ports = [
    {
      name           = "app-port"
      container_port = 6379
    }
  ]

  env = [
    {
      name  = "ALLOW_EMPTY_PASSWORD"
      value = "yes"
    },
  ]
}
