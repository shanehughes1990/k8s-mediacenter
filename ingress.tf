resource "kubernetes_namespace_v1" "ingress" {
  metadata {
    name = "ingress"
  }
}


module "ingress" {
  depends_on = [kubernetes_namespace_v1.ingress]
  source     = "./modules/ingress"
  namespace  = kubernetes_namespace_v1.ingress.metadata[0].name
  cloudflare_config = {
    acme_email = var.acme_email
    api_token  = var.provider_config.cloudflare.api_token
  }
}
