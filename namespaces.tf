locals {
  namespaces = [
    "ingress",
    "utils",
    "db",
    "media",
  ]
}

resource "kubernetes_namespace_v1" "namespace" {
  for_each = { for n in local.namespaces : n => n }
  metadata {
    name = each.value
  }
}
