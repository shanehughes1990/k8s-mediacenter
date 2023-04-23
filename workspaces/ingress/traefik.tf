resource "kubernetes_secret_v1" "traefik" {
  metadata {
    name      = "default-cloudflare-tls"
    namespace = local.environment
  }

  data = {
    "tls.crt" = base64decode(var.cloudflare_config.tls_crt)
    "tls.key" = base64decode(var.cloudflare_config.tls_key)
  }
}

resource "kubernetes_manifest" "auth_forward_middlewaree" {
  depends_on = [kubernetes_namespace_v1.namespace]
  manifest = {
    "apiVersion" : "traefik.containo.us/v1alpha1",
    "kind" : "Middleware",
    "metadata" : {
      "name" : "organizr-admin-middleware"
      "namespace" : local.environment
    },
    "spec" : {
      "forwardAuth" : {
        "address" : "https://web.${var.cloudflare_config.zone_name}/api/v2/auth/$1"
      }
    }
  }
}

resource "helm_release" "traefik" {
  depends_on = [kubernetes_namespace_v1.namespace, kubernetes_secret_v1.traefik]
  namespace  = local.environment
  repository = "https://traefik.github.io/charts"
  chart      = "traefik"
  version    = "22.1.0"
  name       = "traefik"

  values = [
    yamlencode(
      {
        "deployment" : {
          "enabled" : true,
          "replicas" : 3,
        }
        "ingressClass" : {
          "enabled" : true,
          "isDefaultClass" : true,
        }
        "ingressRoute" : {
          "dashboard" : {
            "enabled" : false,
          }
        }
        "logs" : {
          "general" : {
            "level" : "DEBUG"
          }
        }
        "service" : {
          "enabled" : true,
          "type" : "NodePort"
        }
        "ports" : {
          "web" : {
            "nodePort" : "32760"
          }
          "websecure" : {
            "nodePort" : "32761"
          }
        }
        "tlsStore" : {
          "default" : {
            "defaultCertificate" : {
              "secretName" : kubernetes_secret_v1.traefik.metadata[0].name
            }
          }
        }
      }
    )
  ]
}
