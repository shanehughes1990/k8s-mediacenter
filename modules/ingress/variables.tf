variable "namespace" {
  description = "namespace to deploy module too"
  type        = string
}

variable "cloudflare_config" {
  description = "COnfiguration for cloudflare"
  type = object({
    api_token  = string
    acme_email = string
  })
}

variable "nginx_config" {
  description = "Configuration of nginx helm chart"
  type = object({
    kind          = optional(string, "Deployment")
    replicas      = optional(number, 3)
    min_available = optional(number, 1)
    node_ports = optional(object({
      http  = optional(number, 32766)
      https = optional(number, 32767)
    }), {})
  })

  default = {}

  // Validate kind
  validation {
    condition     = contains(["Deployment", "DaemonSet"], var.nginx_config.kind)
    error_message = "Valid values are 'Deployment' & 'DaemonSet'"
  }

  // validate node port port range
  validation {
    condition     = var.nginx_config.node_ports.http >= 30000 && var.nginx_config.node_ports.https >= 30000 && var.nginx_config.node_ports.http <= 32767 && var.nginx_config.node_ports.https <= 32767
    error_message = "Node port must be in the range of 30000 - 32767"
  }

  // validate that min available is equal to or less than replicas
  validation {
    condition     = var.nginx_config.min_available <= var.nginx_config.replicas
    error_message = "Must be equal to or less than the amount of replicas that are set"
  }
}
