locals {
  tls_cluster_issuer = "letsencrypt-production-issuer"
  common_env = [
    {
      name  = "PUID"
      value = 1000
    },
    {
      name  = "PGID"
      value = 1000
    },
    {
      name  = "TZ"
      value = "America/Toronto"
    }
  ]
  basic_auth_annotations = {
    "nginx.ingress.kubernetes.io/auth-type"   = "basic"
    "nginx.ingress.kubernetes.io/auth-secret" = kubernetes_secret_v1.basic_auth.metadata[0].name
    "nginx.ingress.kubernetes.io/auth-realm"  = "Basic auth required"
  }
}
