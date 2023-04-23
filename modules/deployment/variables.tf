variable "name" {
  description = "name prefix to append to all resources"
  type        = string
}

variable "namespace" {
  description = "namespace to deploy resources too"
  type        = string
}

variable "replicas" {
  description = "number of replicas to deploy"
  type        = number

  default = 1
}

variable "progress_deadline_seconds" {
  description = "the maximum time in seconds for a deployment to make progress before it is considered to be failed"
  type        = number

  default = 600
}

variable "deployment_strategy" {
  description = "the deployment strategy to use to replace existing pods with new ones"
  type = object({
    type = optional(string, "Recreate")
    rolling_update = optional(object({
      max_surge       = optional(number, 1)
      max_unavailable = optional(number, 1)
    }), null)
  })

  default = {}
}

variable "image_url" {
  description = "container image url"
  type        = string
}

variable "image_tag" {
  description = "container image tag"
  type        = string
}

variable "image_pull_policy" {
  description = "Image policy to apply when rolling out container"
  type        = string

  default = null
}

variable "ports" {
  description = "container ports to add to deployment"
  type = list(object({
    name           = string
    container_port = number
    protocol       = optional(string, "TCP")
    service_type   = optional(string, "ClusterIP")
    cluster_ip     = optional(string, null)
    node_port      = optional(number, null)
    ingress = optional(list(object({
      domain_match_pattern   = string
      strip_prefix           = optional(string, null)
      enforce_https          = optional(bool, true)
      additional_annotations = optional(map(string))
    })))
  }))

  default = null
}

variable "env" {
  description = "environment variables to pass too running container"
  type = list(object({
    name      = string
    value     = string
    is_secret = optional(bool, false)
    is_volume = optional(object({
      default_mode = optional(string, "0644")
      sub_path     = optional(string, null)
      mount_path   = string
    }))
  }))

  default = null
}

variable "host_directories" {
  description = "host directories to mount to container"
  type = list(object({
    name       = string
    host_path  = string
    mount_path = string
    type       = optional(string, "DirectoryOrCreate")
  }))

  default = null
}

variable "ram_disks" {
  description = "ram disk directories to mount to container"
  type = list(object({
    name       = string
    mount_path = string
    size_limit = optional(string, "8Gi")
  }))

  default = null
}

variable "tmp_disks" {
  description = "empty directories to mount to container"
  type = list(object({
    name       = string
    mount_path = string
  }))

  default = null
}

variable "secret_volumes" {
  description = "volumes to mount that come from secrets"
  type = list(object({
    name         = string
    mount_path   = string
    default_mode = optional(string, "0644")
    data         = optional(map(any))
  }))

  default = null
}

variable "command" {
  description = "container runtime commands"
  type        = list(string)

  default = null
}

variable "args" {
  description = "container runtime arguments"
  type        = list(string)

  default = null
}

variable "service_account_name" {
  description = "name of the service account to bind deployment too"
  type        = string

  default = null
}

variable "deployment_annotations" {
  description = "deployment annotations to add to pod spec"
  type        = map(string)

  default = null
}

variable "metadata_annotations" {
  description = "deployment metadata annotations to add to pod spec"
  type        = map(string)

  default = null
}

variable "resources" {
  description = "deployment resource specification"
  type = object({
    requests = optional(object({
      cpu    = optional(string, null)
      memory = optional(string, null)
    }), {})
    limits = optional(object({
      cpu    = optional(string, null)
      memory = optional(string, null)
      gpu    = optional(number, null)
    }), {})
  })

  default = null
}

variable "container_security_context" {
  description = "SecurityContext holds pod-level security attributes and common container settings"
  type = object({
    allow_privilege_escalation = optional(bool, false)
    read_only_root_filesystem  = optional(bool, false)
    run_as_user                = optional(number, null)
    run_as_group               = optional(number, null)
  })

  default = null
}
