resource "kubernetes_secret_v1" "app" {
  count = length({ for e, env in nonsensitive(sensitive(coalesce(var.env, []))) : e => env if env.is_secret == true }) > 0 ? 1 : 0
  metadata {
    name      = var.name
    namespace = var.namespace
  }

  data = { for s in var.env : s.name => s.value if s.is_secret == true }
}

resource "kubernetes_secret_v1" "secret_volume" {
  for_each = { for e, env in nonsensitive(sensitive(coalesce(var.secret_volumes, []))) : e => env }
  metadata {
    name      = "${var.name}-${each.value.name}"
    namespace = var.namespace
  }

  # data = { for s in var.env : s.name => s.value if s.is_secret == true }
  data = { for s in each.value.data != null ? each.value.data : {} : s.name => s.value }
}
