resource "kubernetes_ingress_v1" "app" {
  depends_on = [kubernetes_service_v1.app]
  for_each   = { for p in coalesce(var.ports, []) : p.name => p if p.is_ingress != null }

  metadata {
    name      = format("%s-%s", var.name, each.value.name)
    namespace = var.namespace

    annotations = merge(
      {
        "cert-manager.io/cluster-issuer"              = each.value.is_ingress.tls_cluster_issuer
        "nginx.ingress.kubernetes.io/ssl-redirect"    = each.value.is_ingress.enforce_https
        "nginx.ingress.kubernetes.io/proxy-body-size" = each.value.is_ingress.proxy_body_size
      },
      each.value.is_ingress.additional_annotations
    )
  }

  spec {
    ingress_class_name = "nginx"

    tls {
      hosts       = each.value.is_ingress.domains.*.name
      secret_name = format("%s-%s-https", var.name, each.value.name)
    }

    dynamic "rule" {
      for_each = each.value.is_ingress.domains
      content {
        host = rule.value.name
        http {
          path {
            path      = rule.value.domain_path
            path_type = rule.value.path_type
            backend {
              service {
                name = kubernetes_service_v1.app[each.value.name].metadata[0].name
                port {
                  name = each.value.name
                }
              }
            }
          }
        }
      }
    }
  }
}
