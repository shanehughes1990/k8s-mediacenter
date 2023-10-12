resource "helm_release" "postgres_operator" {
  depends_on = [
    kubernetes_namespace_v1.namespace,
  ]

  name       = "postgres-operator"
  repository = "https://opensource.zalando.com/postgres-operator/charts/postgres-operator"
  chart      = "postgres-operator"
  version    = "1.10.1"
  namespace  = kubernetes_namespace_v1.namespace.metadata[0].name
}
