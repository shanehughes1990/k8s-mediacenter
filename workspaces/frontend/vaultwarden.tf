module "vaultwarden" {
  depends_on           = [kubernetes_namespace_v1.namespace]
  source               = "../../modules/deployment"
  name                 = "vaultwarden"
  namespace            = kubernetes_namespace_v1.namespace.metadata[0].name
  image_url            = "vaultwarden/server"
  image_tag            = "latest"
  metadata_annotations = local.keel_annotations

  ports = [
    {
      name           = "app-port"
      container_port = 80
      ingress = [
        {
          domain_match_pattern = "Host(`vault.${var.cloudflare_config.zone_name}`)"
        },
      ]
    },
  ]

  env = [
    {
      name  = "SENDS_ALLOWED"
      value = true
    },
    {
      name  = "EMERGENCY_ACCESS_ALLOWED"
      value = true
    },
    {
      name  = "DISABLE_ICON_DOWNLOAD"
      value = true
    },
    {
      name  = "SIGNUPS_ALLOWED"
      value = false
    },
    {
      name      = "ADMIN_TOKEN"
      value     = var.vaultwarden_config.admin_token
      is_secret = true
    },
    {
      name  = "DISABLE_ADMIN_TOKEN"
      value = false
    },
    {
      name  = "INVITATIONS_ALLOWED"
      value = false
    },
    {
      name  = "DOMAIN"
      value = "https://vault.${var.cloudflare_config.zone_name}"
    },
    {
      name      = "SMTP_HOST"
      value     = var.vaultwarden_config.smtp_host
      is_secret = true
    },
    {
      name      = "SMTP_PORT"
      value     = var.vaultwarden_config.smtp_port
      is_secret = true
    },
    {
      name      = "SMTP_FROM_NAME"
      value     = var.vaultwarden_config.smtp_from_name
      is_secret = true
    },
    {
      name      = "SMTP_FROM"
      value     = var.vaultwarden_config.smtp_username
      is_secret = true
    },
    {
      name      = "SMTP_USERNAME"
      value     = var.vaultwarden_config.smtp_username
      is_secret = true
    },
    {
      name      = "SMTP_PASSWORD"
      value     = var.vaultwarden_config.smtp_password
      is_secret = true
    },
    {
      name  = "SMTP_TIMEOUT"
      value = var.vaultwarden_config.smtp_timeout
    },
  ]

  host_directories = [
    {
      name       = "config"
      host_path  = format("%s/%s", var.directory_config.appdata, "vaultwarden")
      mount_path = "/data"
    }
  ]
}
