module "ingress" {
  depends_on = [kubernetes_namespace_v1.namespace]
  source     = "./modules/ingress"
  namespace  = kubernetes_namespace_v1.namespace[local.namespaces[0]].metadata[0].name
  cloudflare_config = {
    acme_email = var.provider_config.cloudflare.email
    api_token  = var.provider_config.cloudflare.api_token
  }
}
