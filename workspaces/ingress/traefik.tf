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
        "providers" : {
          "kubernetesCRD" : {
            "allowCrossNamespace" : true
          }
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
