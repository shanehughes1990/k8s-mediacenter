resource "kubernetes_service_v1" "app" {
  count = length({ for c, container in var.containers : c => container if container.ports != null }) > 0 ? 1 : 0
  metadata {
    name      = var.name
    namespace = var.namespace
  }

  spec {
    type = "ClusterIP"
    selector = {
      app = var.name
    }

    dynamic "port" {
      for_each = flatten([for c in var.containers : c.ports != null ? c.ports : []])
      content {
        name        = port.value.name
        port        = port.value.container_port
        target_port = port.value.name
      }
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
