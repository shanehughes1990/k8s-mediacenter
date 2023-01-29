resource "kubernetes_service_v1" "app" {
  for_each = { for p in coalesce(var.ports, []) : p.name => p }
  metadata {
    name      = format("%s-%s", var.name, each.value.name)
    namespace = var.namespace
  }

  spec {
    type       = each.value.service_type
    cluster_ip = each.value.cluster_ip
    selector = {
      app = var.name
    }

    port {
      name        = each.value.name
      port        = each.value.container_port
      protocol    = each.value.protocol
      target_port = each.value.name
      node_port   = each.value.node_port
    }
  }
}
