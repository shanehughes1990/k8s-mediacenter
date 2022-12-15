resource "kubernetes_persistent_volume_claim_v1" "app" {
  for_each = merge([for c in var.containers :
    { for pvc in coalesce(c.persistent_volume_claims, []) :
      pvc.claim_name => pvc
    }
    ]...
  )

  metadata {
    name      = each.value.claim_name
    namespace = var.namespace
  }

  spec {
    access_modes       = ["ReadWriteOnce"]
    storage_class_name = each.value.storage_class_name != null ? each.value.storage_class_name : "microk8s-hostpath"
    resources {
      requests = {
        storage = each.value.storage
      }
    }
  }
}
