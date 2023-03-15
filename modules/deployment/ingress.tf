resource "kubernetes_ingress_v1" "app" {
  depends_on = [kubernetes_service_v1.app]
  for_each = merge([for p in nonsensitive(sensitive(coalesce(var.ports, []))) :
    { for index, i in nonsensitive(sensitive(coalesce(p.ingress, []))) :
      format("%s-%d", p.name, index) => {
        name                   = p.name
        index                  = index
        tls_cluster_issuer     = i.tls_cluster_issuer
        enforce_https          = i.enforce_https
        proxy_body_size        = i.proxy_body_size
        additional_annotations = i.additional_annotations
        domains                = i.domains
      } if p.ingress != null
    }
    ]...
  )

  metadata {
    name      = format("%s-%s-%d", var.name, each.value.name, each.value.index)
    namespace = var.namespace

    annotations = merge(
      {
        "cert-manager.io/cluster-issuer"              = each.value.tls_cluster_issuer
        "nginx.ingress.kubernetes.io/ssl-redirect"    = each.value.enforce_https
        "nginx.ingress.kubernetes.io/proxy-body-size" = each.value.proxy_body_size
      },
      each.value.additional_annotations
    )
  }

  spec {
    ingress_class_name = "nginx"

    tls {
      hosts       = each.value.domains.*.name
      secret_name = format("%s-%s-%d-https", var.name, each.value.name, each.value.index)
    }

    dynamic "rule" {
      for_each = each.value.domains
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
