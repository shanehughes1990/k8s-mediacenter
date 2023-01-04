resource "kubernetes_service_v1" "app" {
  for_each = merge(
    [for c in var.containers :
      { for s in coalesce(c.ports, []) :
        s.name => s
      }
    ]...
  )
  metadata {
    name      = var.name
    namespace = var.namespace
  }

  spec {
    type = each.value.service_type
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

  # TODO: This overwrites the first spec if 2 ports are specified
  # dynamic "spec" {
  #   for_each = flatten([for c in var.containers : c.ports != null ? c.ports : []])
  #   content {
  #     type = spec.value.service_type
  #     selector = {
  #       app = var.name
  #     }
  #     port {
  #       name        = spec.value.name
  #       port        = spec.value.container_port
  #       target_port = spec.value.name
  #       node_port   = spec.value.node_port
  #     }
  #   }
  # }
}
