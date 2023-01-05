resource "kubernetes_deployment_v1" "app" {
  depends_on = [
    kubernetes_secret_v1.app,
  ]
  metadata {
    name      = var.name
    namespace = var.namespace
    labels = {
      app = var.name
    }
  }

  spec {
    replicas                  = var.replicas
    progress_deadline_seconds = var.progress_deadline_seconds

    dynamic "strategy" {
      for_each = var.deployment_strategy != null ? [var.deployment_strategy] : []
      content {
        type = strategy.value.type
        dynamic "rolling_update" {
          for_each = strategy.value.rolling_update != null ? strategy.value.rolling_update : {}
          content {
            max_surge       = rolling_update.value.max_surge
            max_unavailable = rolling_update.value.max_unavailable
          }
        }
      }
    }

    selector {
      match_labels = {
        app = var.name
      }
    }

    template {
      metadata {
        labels = {
          app = var.name
        }
      }

      spec {
        # dynamic "security_context" {
        #   for_each = var.security_context != null ? [var.security_context] : []
        #   content {
        #     run_as_user  = security_context.value.run_as_user
        #     run_as_group = security_context.value.run_as_group
        #     fs_group     = security_context.value.fs_group
        #   }
        # }

        container {
          image   = format("%s:%s", var.image_url, var.image_tag)
          name    = var.name
          command = var.command
          args    = var.args

          dynamic "port" {
            for_each = coalesce(var.ports, [])
            content {
              name           = port.value.name
              container_port = port.value.container_port
              protocol       = port.value.protocol
            }
          }

          dynamic "env" {
            // this is weird but here because you can have a list of env's without secrets so have to mark all as sensitive then nonsensitive
            for_each = { for e, env in nonsensitive(sensitive(coalesce(var.env, []))) : e => env if env.is_secret == false }
            content {
              name  = env.value.name
              value = env.value.value
            }
          }

          dynamic "env" {
            for_each = length({ for e, env in nonsensitive(sensitive(coalesce(var.env, []))) : e => env if env.is_secret == true }) > 0 ? [{
              name = "SECRET_CHANGE"
              # value = "SHA"
              value = sha1(jsonencode(merge(kubernetes_secret_v1.app[0].data)))
            }] : []
            content {
              name  = env.value.name
              value = env.value.value
            }
          }

          dynamic "env" {
            for_each = { for e, env in nonsensitive(sensitive(coalesce(var.env, []))) : e => env if env.is_secret == true && env.is_volume == null }
            content {
              name = env.value.name
              value_from {
                secret_key_ref {
                  name = kubernetes_secret_v1.app[0].metadata.0.name
                  key  = env.value.name
                }
              }
            }
          }

          dynamic "volume_mount" {
            for_each = { for h in var.host_directories != null ? var.host_directories : [] : h.name => h }
            content {
              name       = volume_mount.value.name
              mount_path = volume_mount.value.mount_path
            }
          }

          dynamic "volume_mount" {
            for_each = { for e, env in nonsensitive(sensitive(coalesce(var.env, []))) : e => env if env.is_volume != null }
            content {
              name       = lower(replace(volume_mount.value.name, "_", "-"))
              mount_path = volume_mount.value.is_volume.mount_path
              sub_path   = volume_mount.value.is_volume.sub_path
            }
          }
        }

        dynamic "volume" {
          for_each = { for h in var.host_directories != null ? var.host_directories : [] : h.name => h }
          content {
            name = volume.value.name
            host_path {
              type = volume.value.type
              path = volume.value.host_path
            }
          }
        }

        dynamic "volume" {
          for_each = { for e, env in nonsensitive(sensitive(coalesce(var.env, []))) : e => env if env.is_secret == true && env.is_volume != null }
          content {
            name = lower(replace(volume.value.name, "_", "-"))
            secret {
              default_mode = volume.value.is_volume.default_mode
              secret_name  = kubernetes_secret_v1.app[0].metadata[0].name
              dynamic "items" {
                for_each = volume.value.is_volume.sub_path != null ? [volume.value] : []
                content {
                  key  = items.value.name
                  path = items.value.is_volume.sub_path
                }
              }
            }
          }
        }
      }
    }
  }
}
