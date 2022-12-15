# resource "cloudflare_record" "dns_recourd" {
#   for_each = merge([for c in var.containers :
#     { for p in coalesce(c.ports, []) :
#       p.name => p if p.is_ingress != null
#     }
#     ]...
#   )
#   type    = "CNAME"
#   zone_id = each.value.zone_id
#   value   = each.value.value
#   name    = each.value.domain_name
# }