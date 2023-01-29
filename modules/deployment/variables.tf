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

variable "ports" {
  description = "container ports to add to deployment"
  type = list(object({
    name           = string
    container_port = number
    protocol       = optional(string, "TCP")
    service_type   = optional(string, "ClusterIP")
    cluster_ip     = optional(string, null)
    node_port      = optional(number, null)
    is_ingress = optional(object({
      tls_cluster_issuer     = string
      enforce_https          = optional(bool, true)
      proxy_body_size        = optional(string, "1m")
      domain_path            = optional(string, "/")
      path_type              = optional(string, "Prefix")
      additional_annotations = optional(map(string))
      domains = list(object({
        name        = string
        domain_path = optional(string, "/")
        path_type   = optional(string, "ImplementationSpecific")
      }))
    }))
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
