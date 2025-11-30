#! NOT BEING MIGRATED
module "redis" {
  depends_on           = [kubernetes_namespace_v1.namespace]
  source               = "../../modules/deployment"
  name                 = "redis"
  namespace            = kubernetes_namespace_v1.namespace.metadata[0].name
  image_url            = "bitnami/redis"
  image_tag            = "latest"
  metadata_annotations = local.keel_annotations

  ports = [
    {
      name           = "app-port"
      service_type   = "NodePort"
      container_port = 6379
      node_port      = 30007
    }
  ]

  env = [
    {
      name  = "ALLOW_EMPTY_PASSWORD"
      value = "yes"
    },
  ]
}
