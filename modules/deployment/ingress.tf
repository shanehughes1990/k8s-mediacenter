resource "kubernetes_ingress_v1" "app" {
  depends_on = [kubernetes_service_v1.app]
  for_each = merge([for c in var.containers :
    { for p in coalesce(c.ports, []) :
      p.name => p if p.is_ingress != null
    }
    ]...
  )

  metadata {
    name      = each.value.name
    namespace = var.namespace

    # annotations = merge(
    #   {
    #     "kubernetes.io/ingress.class"                 = "nginx"
    #     "cert-manager.io/cluster-issuer"              = each.value.is_ingress.tls_cluster_issuer
    #     "nginx.ingress.kubernetes.io/ssl-redirect"    = each.value.is_ingress.enforce_https != null ? each.value.is_ingress.enforce_https : true
    #     "nginx.ingress.kubernetes.io/proxy-body-size" = each.value.is_ingress.proxy_body_size != null ? each.value.is_ingress.proxy_body_size : "1m"
    #   },
    #   each.value.is_ingress.additional_annotations
    # )
  }

  spec {
    tls {
      hosts       = [each.value.is_ingress.domain_name]
      secret_name = format("%s-%s-https", var.name, each.value.name)
    }
    rule {
      host = each.value.is_ingress.domain_name
      http {
        path {
          path      = each.value.is_ingress.domain_path != null ? each.value.is_ingress.domain_path : "/"
          path_type = each.value.is_ingress.path_type != null ? each.value.is_ingress.path_type : "Prefix"
          backend {
            service {
              name = kubernetes_service_v1.app[0].metadata.0.name
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