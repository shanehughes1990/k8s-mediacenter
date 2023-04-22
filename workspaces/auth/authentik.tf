# resource "cloudflare_record" "authentik_server" {
#   type    = "CNAME"
#   zone_id = var.cloudflare_config.zone_id
#   value   = var.cloudflare_config.zone_name
#   name    = format("%s.%s", "id", var.cloudflare_config.zone_name)
# }

# resource "helm_release" "authentik" {
#   depends_on = [
#     kubernetes_namespace_v1.namespace,
#   ]

#   name       = "authentik"
#   repository = "https://charts.goauthentik.io"
#   chart      = "authentik"
#   version    = "2023.3.1"
#   namespace  = kubernetes_namespace_v1.namespace.metadata[0].name

#   values = [
#     yamlencode({
#       "authentik" = {
#         "secret_key" = var.authentik_config.secret_key
#         "log_level"  = "info"
#         "error_reporting" = {
#           "enabled" = false
#         }
#         "postgresql" = {
#           "name"     = "authentik"
#           "host"     = data.terraform_remote_state.shared.outputs.postgres.svc
#           "user"     = data.terraform_remote_state.shared.outputs.postgres.username
#           "password" = data.terraform_remote_state.shared.outputs.postgres.password
#         }
#         "redis" = {
#           "host" = data.terraform_remote_state.shared.outputs.redis.svc
#         }
#       }
#       "ingress" = {
#         "enabled"          = true
#         "ingressClassName" = "nginx"
#         "annotations" = {
#           "cert-manager.io/cluster-issuer"              = local.tls_cluster_issuer
#           "nginx.ingress.kubernetes.io/proxy-body-size" = "1m"
#           "nginx.ingress.kubernetes.io/ssl-redirect"    = "true"
#         }
#         "tls" = [
#           {
#             "hosts"      = [cloudflare_record.authentik_server.name]
#             "secretName" = "authentik-https"
#           }
#         ]
#         "hosts" = [
#           {
#             "host" = cloudflare_record.authentik_server.name
#             "paths" = [
#               {
#                 "path"     = "/"
#                 "pathType" = "Prefix"
#               }
#             ]
#           }
#         ]
#       },
#       // disable internal postgres deployment
#       "postgresql" = {
#         "enabled" = false
#       }
#       // disable internal redis deployment
#       "redis" = {
#         "enabled" = false
#       }
#     })
#   ]
# }
