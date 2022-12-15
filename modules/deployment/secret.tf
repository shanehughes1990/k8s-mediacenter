resource "kubernetes_secret_v1" "app" {
  count = length({ for c, container in var.containers : c => container if container.env_secrets != null }) > 0 ? 1 : 0
  metadata {
    name      = var.name
    namespace = var.namespace
  }

  data = merge(
    [for c in var.containers :
      { for s in coalesce(c.env_secrets, []) :
        s.name => s.value
      }
    ]...
  )
}