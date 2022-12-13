resource "kubernetes_secret_v1" "certificate_manager" {
  metadata {
    name      = local.certificate_manager_name
    namespace = var.namespace
  }

  data = {
    api_token = var.cloudflare_config.api_token
  }
}

// I use kubectl_manifest because of a bug in kubernetes provider
// that does not allow me to plan without cert manager being present first
// because of the api version not being present until deployment
resource "kubectl_manifest" "certificate_manager" {
  for_each        = { for i in local.cluster_issuer : i.name => i }
  depends_on      = [kubernetes_secret_v1.certificate_manager, helm_release.certificate_manager]
  validate_schema = false
  yaml_body = yamlencode({
    "apiVersion" = "cert-manager.io/v1",
    "kind"       = "ClusterIssuer",
    "metadata" = {
      "name" = each.value.name
    }
    "spec" = {
      "acme" = {
        "email"  = var.cloudflare_config.acme_email
        "server" = each.value.server
        "privateKeySecretRef" = {
          "name" = each.value.name
        }
        "solvers" = [
          {
            "dns01" = {
              "cloudflare" = {
                "email" = var.cloudflare_config.acme_email
                "apiTokenSecretRef" = {
                  "name" = kubernetes_secret_v1.certificate_manager.metadata[0].name
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

resource "helm_release" "certificate_manager" {
  namespace  = var.namespace
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  version    = "1.10.1"
  name       = local.certificate_manager_name

  dynamic "set" {
    for_each = local.certificate_manager_helm_values
    content {
      name  = set.value.name
      value = set.value.value
    }
  }
}
