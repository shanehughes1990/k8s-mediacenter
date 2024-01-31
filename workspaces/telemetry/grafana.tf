module "grafana" {
  depends_on           = [kubernetes_namespace_v1.namespace]
  source               = "../../modules/deployment"
  name                 = "grafana"
  namespace            = kubernetes_namespace_v1.namespace.metadata[0].name
  image_url            = "grafana/grafana"
  image_tag            = "latest"
  metadata_annotations = local.keel_annotations

  ports = [
    {
      name           = "app-port"
      container_port = 3000
      ingress = [
        {
          domain_match_pattern = "Host(`grafana.${var.cloudflare_config.zone_name}`)"
        },
      ]
    }
  ]

  env = [
    {
      name  = "GF_DATABASE_TYPE"
      value = "mysql"
    },
    {
      name  = "GF_DATABASE_HOST"
      value = "mysql-app-port.shared.svc:3306"
    },
    {
      name  = "GF_DATABASE_NAME"
      value = "grafana"
    },
    {
      name      = "GF_DATABASE_USER"
      value     = var.grafana_config.database_username
      is_secret = true
    },
    {
      name      = "GF_DATABASE_PASSWORD"
      value     = var.grafana_config.database_password
      is_secret = true
    },
    {
      name      = "GF_SECURITY_ADMIN_USER"
      value     = var.grafana_config.admin_username
      is_secret = true
    },
    {
      name      = "GF_SECURITY_ADMIN_PASSWORD"
      value     = var.grafana_config.admin_password
      is_secret = true
    },
  ]
}
