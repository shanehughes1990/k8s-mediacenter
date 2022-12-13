resource "helm_release" "nginx" {
  namespace  = var.namespace
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  version    = "4.4.0"
  name       = "web"

  dynamic "set" {
    for_each = local.nginx_helm_values
    content {
      name  = set.value.name
      value = set.value.value
    }
  }
}
