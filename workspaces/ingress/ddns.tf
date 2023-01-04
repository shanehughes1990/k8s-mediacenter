module "cloudflare_ddns" {
  depends_on = [kubernetes_namespace_v1.namespace]
  source     = "../../modules/deployment"
  name       = "cloudflare-ddns"
  namespace  = kubernetes_namespace_v1.namespace.metadata[0].name

  containers = [
    {
      name      = "cloudflare-ddns"
      image_url = "cr.hotio.dev/hotio/cloudflareddns"
      image_tag = "latest"

      env = [
        {
          name  = "PUID"
          value = 1000
        },
        {
          name  = "PGID"
          value = 1000
        },
        {
          name  = "TZ"
          value = "America/Toronto"
        },
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
      ]

      env_secrets = [
        {
          name  = "CF_APITOKEN"
          value = var.cloudflare_config.api_token
        },
        {
          name  = "CF_HOSTS"
          value = var.cloudflare_config.zone_name
        },
        {
          name  = "CF_ZONES"
          value = var.cloudflare_config.zone_name
        },
      ]
    }
  ]
}
