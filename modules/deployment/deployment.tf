resource "kubernetes_deployment_v1" "app" {
  depends_on = [
    kubernetes_secret_v1.app,
    kubernetes_secret_v1.secret_volume,
  ]

  lifecycle {
    ignore_changes = [
      spec[0].template[0].metadata[0].annotations
    ]
  }

  metadata {
    name        = var.name
    namespace   = var.namespace
    annotations = var.metadata_annotations
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

        annotations = var.deployment_annotations
      }

      spec {
        service_account_name = var.service_account_name

        container {
          image             = format("%s:%s", var.image_url, var.image_tag)
          image_pull_policy = var.image_pull_policy
          name              = var.name
          command           = var.command
          args              = var.args

          dynamic "security_context" {
            for_each = var.container_security_context != null ? [var.container_security_context] : []
            content {
              allow_privilege_escalation = security_context.value.allow_privilege_escalation
              read_only_root_filesystem  = security_context.value.read_only_root_filesystem
              run_as_user                = security_context.value.run_as_user
              run_as_group               = security_context.value.run_as_group
            }
          }

          dynamic "port" {
            for_each = nonsensitive(sensitive(coalesce(var.ports, [])))
            content {
              name           = port.value.name
              container_port = port.value.container_port
              protocol       = port.value.protocol
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
            // this is weird but here because you can have a list of env's without secrets so have to mark all as sensitive then nonsensitive
            for_each = { for e, env in nonsensitive(sensitive(coalesce(var.env, []))) : e => env if env.is_secret == false }
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
            for_each = { for h in var.ram_disks != null ? var.ram_disks : [] : h.name => h }
            content {
              name       = volume_mount.value.name
              mount_path = volume_mount.value.mount_path
            }
          }

          dynamic "volume_mount" {
            for_each = { for h in var.tmp_disks != null ? var.tmp_disks : [] : h.name => h }
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

          dynamic "volume_mount" {
            for_each = { for e, env in nonsensitive(sensitive(coalesce(var.secret_volumes, []))) : e => env }
            content {
              name       = volume_mount.value.name
              mount_path = volume_mount.value.mount_path
            }
          }

          dynamic "resources" {
            for_each = var.resources != null ? [var.resources] : []
            content {
              requests = {
                cpu    = resources.value.requests.cpu
                memory = resources.value.requests.memory
              }
              limits = {
                cpu    = resources.value.limits.cpu
                memory = resources.value.limits.memory
                "nvidia.com/gpu" : resources.value.limits.gpu
              }
            }
          }

          dynamic "readiness_probe" {
            for_each = var.readiness_probe != null ? [var.readiness_probe] : []
            content {
              dynamic "http_get" {
                for_each = readiness_probe.value.http_get != null ? [readiness_probe.value.http_get] : []
                content {
                  path   = http_get.value.path
                  port   = http_get.value.port
                  scheme = http_get.value.scheme
                }
              }

              initial_delay_seconds = readiness_probe.value.initial_delay_seconds
              period_seconds        = readiness_probe.value.period_seconds
              success_threshold     = readiness_probe.value.success_threshold
              timeout_seconds       = readiness_probe.value.timeout_seconds
            }
          }

          dynamic "liveness_probe" {
            for_each = var.liveness_probe != null ? [var.liveness_probe] : []
            content {
              dynamic "http_get" {
                for_each = liveness_probe.value.http_get != null ? [liveness_probe.value.http_get] : []
                content {
                  path   = http_get.value.path
                  port   = http_get.value.port
                  scheme = http_get.value.scheme
                }
              }

              initial_delay_seconds = liveness_probe.value.initial_delay_seconds
              period_seconds        = liveness_probe.value.period_seconds
              success_threshold     = liveness_probe.value.success_threshold
              timeout_seconds       = liveness_probe.value.timeout_seconds
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
          for_each = { for h in var.ram_disks != null ? var.ram_disks : [] : h.name => h }
          content {
            name = volume.value.name
            empty_dir {
              medium     = "Memory"
              size_limit = volume.value.size_limit
            }
          }
        }

        dynamic "volume" {
          for_each = { for h in var.tmp_disks != null ? var.tmp_disks : [] : h.name => h }
          content {
            name = volume.value.name
            empty_dir {}
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

        dynamic "volume" {
          for_each = { for e, env in nonsensitive(sensitive(coalesce(var.secret_volumes, []))) : e => {
            name         = env.name
            mount_path   = env.mount_path
            default_mode = env.default_mode
            data         = env.data
            index        = e
          } }
          content {
            name = lower(replace(volume.value.name, "_", "-"))
            secret {
              default_mode = volume.value.default_mode
              secret_name  = kubernetes_secret_v1.secret_volume[volume.value.index].metadata[0].name
            }
          }
        }
      }
    }
  }
}
