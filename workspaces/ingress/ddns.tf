module "cloudflare_ddns" {
  depends_on           = [kubernetes_namespace_v1.namespace]
  source               = "../../modules/deployment"
  name                 = "cloudflare-ddns"
  namespace            = kubernetes_namespace_v1.namespace.metadata[0].name
  image_url            = "ghcr.io/hotio/cloudflareddns"
  image_tag            = "latest"
  metadata_annotations = local.keel_annotations

  env = setunion(
    local.common_env,
    [
      {
        name  = "UMASK"
        value = 002
      },
      {
        name  = "INTERVAL"
        value = 300
      },
      {
        name  = "DETECTION_MODE"
        value = "dig-whoami.cloudflare"
      },
      {
        name  = "LOG_LEVEL"
        value = 2
      },
      {
        name  = "CF_RECORDTYPES"
        value = "A"
      },
      {
        name      = "CF_APITOKEN"
        value     = var.cloudflare_config.api_token
        is_secret = true
      },
      {
        name      = "CF_HOSTS"
        value     = "${var.cloudflare_config.zone_name};*.${var.cloudflare_config.zone_name}"
        is_secret = true
      },
      {
        name      = "CF_ZONES"
        value     = var.cloudflare_config.zone_name
        is_secret = true
      },
    ]
  )
}
