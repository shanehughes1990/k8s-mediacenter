resource "helm_release" "nginx" {
  depends_on = [kubernetes_namespace_v1.namespace]
  namespace  = local.environment
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  version    = "4.4.0"
  name       = "web"

  dynamic "set" {
    for_each = [
      {
        name  = "controller.kind"
        value = "Deployment"
      },
      {
        name  = "controller.replicaCount"
        value = 3
      },
      {
        name  = "controller.minAvailable"
        value = 1
      },
      {
        name  = "controller.publishService.enabled"
        value = true
      },
      {
        name  = "controller.service.type"
        value = "NodePort"
      },
      {
        name  = "controller.service.nodePorts.http"
        value = 32766
      },
      {
        name  = "controller.service.nodePorts.https"
        value = 32767
      },
      {
        name  = "rbac.create"
        value = true
      },
      {
        name  = "defaultBackend.enabled"
        value = false
      },
      {
        name  = "controller.admissionWebhooks.enabled"
        value = true
      },
    ]

    content {
      name  = set.value.name
      value = set.value.value
    }
  }
}
