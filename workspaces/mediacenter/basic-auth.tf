# resource "cloudflare_record" "basic_auth" {
#   type    = "CNAME"
#   zone_id = var.cloudflare_config.zone_id
#   value   = var.cloudflare_config.zone_name
#   name    = format("%s.%s", "360", var.cloudflare_config.zone_name)
# }

# resource "kubernetes_secret_v1" "basic_auth" {
#   metadata {
#     name      = "basic-auth"
#     namespace = kubernetes_namespace_v1.namespace.metadata[0].name
#   }

#   data = {
#     auth = "${var.basic_auth.username}:${bcrypt(var.basic_auth.password)}"
#   }
# }
