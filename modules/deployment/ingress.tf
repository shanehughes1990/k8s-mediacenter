resource "kubernetes_manifest" "app" {
  depends_on = [kubernetes_service_v1.app]
  for_each = merge([for p in nonsensitive(sensitive(coalesce(var.ports, []))) :
    { for index, i in nonsensitive(sensitive(coalesce(p.ingress, []))) :
      format("%s-%d", p.name, index) => {
        name                   = p.name
        index                  = index
        additional_annotations = i.additional_annotations
        domain_match_pattern   = i.domain_match_pattern
        enforce_https          = i.enforce_https
      } if p.ingress != null
    }
    ]...
  )

  manifest = {
    "apiVersion" : "traefik.containo.us/v1alpha1",
    "kind" : "IngressRoute",
    "metadata" : {
      "name" : format("%s-%s-%d", var.name, each.value.name, each.value.index)
      "namespace" : var.namespace
      "annotations" = merge(
        {
          "kubernetes.io/ingress.class" : "traefik"
          "ingress.kubernetes.io/ssl-redirect" : each.value.enforce_https
        },
        each.value.additional_annotations
      )
    },
    "spec" : {
      "entryPoints" : ["websecure"],
      "routes" : [
        {
          "match" : each.value.domain_match_pattern,
          "kind" : "Rule",
          "services" : [
            {
              "kind" : "Service"
              "name" = kubernetes_service_v1.app[each.value.name].metadata[0].name
              "namespace" : var.namespace
              "port" : each.value.name
            }
          ]
        }
      ],
    }
  }
}

# resource "kubernetes_manifest" "app_strip_prefix" {
#   depends_on = [kubernetes_service_v1.app]
#   for_each = merge([for p in nonsensitive(sensitive(coalesce(var.ports, []))) :
#     { for index, i in nonsensitive(sensitive(coalesce(p.ingress, []))) :
#       format("%s-%d", p.name, index) => {
#         name         = p.name
#         index        = index
#         strip_prefix = i.strip_prefix
#       } if p.ingress != null && i.strip_prefix != null
#     }
#     ]...
#   )

#   manifest = {
#     "apiVersion" : "traefik.containo.us/v1alpha1",
#     "kind" : "Middleware",
#     "metadata" : {
#       "name" : format("%s-%s-%d", var.name, each.value.name, each.value.index)
#       "namespace" : var.namespace
#     },
#     "spec" : {
#       "stripPrefix" : {
#         "prefixes" : [each.value.strip_prefix]
#       }
#     }
#   }
# }
