resource "helm_release" "redis_operator" {
  depends_on = [
    kubernetes_namespace_v1.namespace,
  ]

  name       = "redis-operator"
  repository = "https://spotahome.github.io/redis-operator"
  chart      = "redis-operator"
  version    = "3.2.9"
  namespace  = kubernetes_namespace_v1.namespace.metadata[0].name
}
