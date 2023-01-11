resource "kubernetes_secret_v1" "cert_manager" {
  metadata {
    name      = "cert-manager"
    namespace = local.environment
  }

  data = {
    api_token = var.cloudflare_config.api_token
  }
}

resource "helm_release" "cert_manager" {
  namespace  = local.environment
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  version    = "1.10.1"
  name       = kubernetes_secret_v1.cert_manager.metadata[0].name

  dynamic "set" {
    for_each = [
      {
        name  = "replicaCount"
        value = 3
      },
      {
        name  = "installCRDs"
        value = true
      },
    ]

    content {
      name  = set.value.name
      value = set.value.value
    }
  }
}

// I use kubectl_manifest because of a bug in kubernetes provider
// that does not allow me to plan without cert manager being present first
// because of the api version not being present until deployment
resource "kubectl_manifest" "cert_manager" {
  depends_on = [kubernetes_secret_v1.cert_manager, helm_release.cert_manager]
  for_each = {
    for i in [
      {
        name   = "letsencrypt-production-issuer"
        server = "https://acme-v02.api.letsencrypt.org/directory"
      },
      {
        name   = "letsencrypt-staging-issuer"
        server = "https://acme-staging-v02.api.letsencrypt.org/directory"
      },
    ] : i.name => i
  }

  validate_schema = false
  yaml_body = yamlencode({
    "apiVersion" = "cert-manager.io/v1",
    "kind"       = "ClusterIssuer",
    "metadata" = {
      "name" = each.value.name
    }
    "spec" = {
      "acme" = {
        "email"  = var.cloudflare_config.email
        "server" = each.value.server
        "privateKeySecretRef" = {
          "name" = each.value.name
        }
        "solvers" = [
          {
            "dns01" = {
              "cloudflare" = {
                "email" = var.cloudflare_config.email
                "apiTokenSecretRef" = {
                  "name" = kubernetes_secret_v1.cert_manager.metadata[0].name
                  "key"  = "api_token"
                }
              }
            }
          }
        ]
      }
    }
  })
}

