resource "kubernetes_deployment_v1" "app" {
  depends_on = [
    kubernetes_secret_v1.app,
    kubernetes_persistent_volume_claim_v1.app,
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

    strategy {
      type = "Recreate"
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
        service_account_name = var.service_account_name
        priority_class_name  = var.priority_class_name

        dynamic "security_context" {
          for_each = var.security_context != null ? [var.security_context] : []
          content {
            run_as_user  = security_context.value.run_as_user
            run_as_group = security_context.value.run_as_group
            fs_group     = security_context.value.fs_group
          }
        }

        dynamic "container" {
          for_each = var.containers != null ? var.containers : []
          content {
            image   = "${container.value.image_url}:${container.value.image_tag}"
            name    = container.value.name
            command = container.value.command
            args    = container.value.args

            dynamic "port" {
              for_each = container.value.ports != null ? container.value.ports : []
              content {
                name           = port.value.name
                container_port = port.value.container_port
                protocol       = port.value.protocol
              }
            }

            dynamic "env" {
              for_each = container.value.env != null ? container.value.env : []
              content {
                name  = env.value.name
                value = env.value.value
              }
            }

            # dynamic "env" {
            #   for_each = length(merge(
            #     [for c in var.containers :
            #       { for s in coalesce(c.env, []) :
            #         s.name => c if s.is_volume != null
            #       }
            #     ]...
            #     )) > 0 ? [{
            #     name  = "CONFIG_MAP_CHANGE"
            #     value = sha1(jsonencode(merge(kubernetes_secret_v1.app[0].data)))
            #   }] : []
            #   content {
            #     name  = env.value.name
            #     value = env.value.value
            #   }
            # }

            dynamic "env" {
              for_each = container.value.env_secrets != null ? [{
                name  = "SECRET_CHANGE"
                value = sha1(jsonencode(merge(kubernetes_secret_v1.app[0].data)))
              }] : []
              content {
                name  = env.value.name
                value = env.value.value
              }
            }

            dynamic "env" {
              for_each = merge({ for c in container.value.env_secrets != null ? container.value.env_secrets : [] : c.name => c if c.is_volume == null })
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

            # dynamic "volume_mount" {
            #   for_each = merge({ for c in container.value.env != null ? container.value.env : [] : c.name => c if c.is_volume != null })
            #   content {
            #     name       = lower(replace(volume_mount.value.name, "_", "-"))
            #     mount_path = volume_mount.value.is_volume.mount_path
            #     sub_path   = volume_mount.value.is_volume.sub_path
            #   }
            # }

            dynamic "volume_mount" {
              for_each = merge({ for c in container.value.env_secrets != null ? container.value.env_secrets : [] : c.name => c if c.is_volume != null })
              content {
                name       = lower(replace(volume_mount.value.name, "_", "-"))
                mount_path = volume_mount.value.is_volume.mount_path
                sub_path   = volume_mount.value.is_volume.sub_path
              }
            }

            dynamic "volume_mount" {
              for_each = merge({ for c in container.value.persistent_volume_claims != null ? container.value.persistent_volume_claims : [] : c.claim_name => c })
              content {
                name       = volume_mount.value.claim_name
                mount_path = volume_mount.value.mount_path
              }
            }

            dynamic "volume_mount" {
              for_each = merge({ for c in container.value.host_directories != null ? container.value.host_directories : [] : c.name => c })
              content {
                name       = volume_mount.value.name
                mount_path = volume_mount.value.mount_path
              }
            }

            dynamic "resources" {
              for_each = container.value.resources != null ? [container.value.resources] : []
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

            dynamic "liveness_probe" {
              for_each = container.value.liveness_probe != null ? [container.value.liveness_probe] : []
              content {
                http_get {
                  path = liveness_probe.value.http_get.path
                  port = liveness_probe.value.http_get.port
                }

                initial_delay_seconds = liveness_probe.value.initial_delay_seconds
                period_seconds        = liveness_probe.value.period_seconds
                timeout_seconds       = liveness_probe.value.timeout_seconds
                failure_threshold     = liveness_probe.value.failure_threshold
                success_threshold     = liveness_probe.value.success_threshold
              }
            }

            dynamic "readiness_probe" {
              for_each = container.value.readiness_probe != null ? [container.value.readiness_probe] : []
              content {
                http_get {
                  path = readiness_probe.value.http_get.path
                  port = readiness_probe.value.http_get.port
                }

                initial_delay_seconds = readiness_probe.value.initial_delay_seconds
                period_seconds        = readiness_probe.value.period_seconds
                timeout_seconds       = readiness_probe.value.timeout_seconds
                failure_threshold     = readiness_probe.value.failure_threshold
                success_threshold     = readiness_probe.value.success_threshold
              }
            }
          }
        }

        # dynamic "volume" {
        #   for_each = merge([for c in var.containers : {
        #     for s in c.env != null ? c.env : [] :
        #     s.name => s if s.is_volume != null
        #     }]...
        #   )
        #   content {
        #     name = lower(replace(volume.value.name, "_", "-"))
        #     config_map {
        #       default_mode = volume.value.is_volume.default_mode
        #       name         = kubernetes_config_map_v1.app[0].metadata.0.name
        #       dynamic "items" {
        #         for_each = volume.value.is_volume.sub_path != null ? [volume.value] : []
        #         content {
        #           key  = items.value.name
        #           path = items.value.is_volume.sub_path
        #         }
        #       }
        #     }
        #   }
        # }

        dynamic "volume" {
          for_each = merge([for c in var.containers : {
            for s in c.env_secrets != null ? c.env_secrets : [] :
            s.name => s if s.is_volume != null
            }]...
          )
          content {
            name = lower(replace(volume.value.name, "_", "-"))
            secret {
              default_mode = volume.value.is_volume.default_mode
              secret_name  = kubernetes_secret_v1.app[0].metadata.0.name
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
          for_each = merge([for c in var.containers : {
            for s in c.persistent_volume_claims != null ? c.persistent_volume_claims : [] :
            s.claim_name => s
            }]...
          )
          content {
            name = volume.value.claim_name
            persistent_volume_claim {
              claim_name = volume.value.claim_name
              read_only  = volume.value.read_only != null ? volume.value.read_only : false
            }
          }
        }

        dynamic "volume" {
          for_each = merge([for c in var.containers : {
            for s in c.host_directories != null ? c.host_directories : [] :
            s.name => s
            }]...
          )
          content {
            name = volume.value.name
            host_path {
              type = volume.value.type
              path = volume.value.host_path
            }
          }
        }
      }
    }
  }
}
