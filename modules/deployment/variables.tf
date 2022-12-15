# Global Settings
variable "name" {
  description = "prefix to apply to all resources"
  type        = string
}

variable "namespace" {
  description = "namespace to deploy resources"
  type        = string
}

variable "replicas" {
  description = "(OPTIONAL) pod replicas to deploy, does nothing if daemonset"
  type        = number

  default = null
}

variable "progress_deadline_seconds" {
  description = "(OPTIONAL) the maximum time in seconds for a deployment to make progress before it is considered to be failed, does nothing if daemonset"
  type        = number

  default = null
}

variable "service_account_name" {
  description = "(OPTIONAL) name of the service account to use to run this pod"
  type        = string

  default = null
}

variable "priority_class_name" {
  description = "(OPTIONAL) indicates the pod's priority"
  type        = string

  default = null
}

variable "containers" {
  description = "containers to deploy in the pod"
  type = list(object({
    image_url = string
    image_tag = string
    name      = string
    command   = optional(list(string))
    args      = optional(list(string))

    env = optional(list(object({
      name  = string
      value = any
      is_volume = optional(object({
        default_mode = optional(string, "0644")
        sub_path     = optional(string, null)
        mount_path   = string
      }))
    })))

    env_secrets = optional(list(object({
      name  = string
      value = any
      is_volume = optional(object({
        default_mode = optional(string, "0644")
        sub_path     = optional(string, null)
        mount_path   = string
      }))
    })))

    ports = optional(list(object({
      name           = string
      container_port = number
      protocol       = optional(string, "TCP")
      # service_type   = optional(string, "ClusterIP")
      # node_port      = optional(number, null)
      is_ingress = optional(object({
        domain_name = string
        # zone_id     = string
        # value       = string
        # domain_path = optional(string)
        # path_type   = optional(string)
        # tls_cluster_issuer     = string
        # enforce_https          = optional(bool)
        # proxy_body_size        = optional(string)
        # additional_annotations = optional(map(string))
      }))
    })))

    resources = optional(object({
      requests = object({
        cpu    = string
        memory = string
      })
      limits = object({
        cpu    = string
        memory = string
      })
    }))

    liveness_probe = optional(object({
      http_get = object({
        path = string
        port = number
      })

      initial_delay_seconds = optional(number)
      period_seconds        = optional(number)
      timeout_seconds       = optional(number)
      failure_threshold     = optional(number)
      success_threshold     = optional(number)
    }))

    readiness_probe = optional(object({
      http_get = object({
        path = string
        port = number
      })

      initial_delay_seconds = optional(number)
      period_seconds        = optional(number)
      timeout_seconds       = optional(number)
      failure_threshold     = optional(number)
      success_threshold     = optional(number)
    }))

    persistent_volume_claims = optional(list(object({
      claim_name         = string
      storage            = string
      mount_path         = string
      storage_class_name = optional(string)
      read_only          = optional(bool)
    })))

    host_directories = optional(list(object({
      name       = string
      host_path  = string
      mount_path = string
      type       = optional(string, "DirectoryOrCreate")
    })))
  }))
}
