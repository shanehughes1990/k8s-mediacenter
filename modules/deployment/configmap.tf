# resource "kubernetes_config_map_v1" "app" {
#   # count = length({ for c, container in var.containers : c => container if container.env != null }) > 0 ? 1 : 0
#   count = length(merge(
#     [for c in var.containers :
#       { for s in coalesce(c.env, []) :
#         s.name => c if s.is_volume != null
#       }
#     ]...
#   )) > 0 ? 1 : 0
#   metadata {
#     name      = var.name
#     namespace = var.namespace
#   }

#   data = merge(
#     [for c in var.containers :
#       { for s in coalesce(c.env, []) :
#         s.name => s.value if s.is_volume != null
#       }
#     ]...
#   )
# }