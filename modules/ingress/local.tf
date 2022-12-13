locals {
  nginx_helm_values = [
    {
      name  = "controller.kind"
      value = var.nginx_config.kind
    },
    {
      name  = "controller.replicaCount"
      value = var.nginx_config.replicas
    },
    {
      name  = "controller.minAvailable"
      value = var.nginx_config.min_available
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
      value = var.nginx_config.node_ports.http
    },
    {
      name  = "controller.service.nodePorts.https"
      value = var.nginx_config.node_ports.https
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

  certificate_manager_helm_values = [
    {
      name  = "replicaCount"
      value = 1
    },
    {
      name  = "installCRDs"
      value = true
    },
  ]

  certificate_manager_name = "certificate-manager"
  cluster_issuer = [
    {
      name   = "letsencrypt-production-issuer"
      server = "https://acme-v02.api.letsencrypt.org/directory"
    },
    {
      name   = "letsencrypt-staging-issuer"
      server = "https://acme-staging-v02.api.letsencrypt.org/directory"
    },
  ]
}
