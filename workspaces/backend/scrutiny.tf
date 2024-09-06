module "scrutiny" {
  depends_on           = [kubernetes_namespace_v1.namespace]
  source               = "../../modules/deployment"
  name                 = "scrutiny"
  namespace            = kubernetes_namespace_v1.namespace.metadata[0].name
  image_url            = "ghcr.io/analogj/scrutiny"
  image_tag            = "master-omnibus"
  metadata_annotations = local.keel_annotations

  ports = [
    {
      name           = "app-port"
      container_port = 8080
      service_type   = "NodePort"
      ingress = [
        {
          domain_match_pattern = "Host(`scrutiny.${var.cloudflare_config.zone_name}`)"
          middlewares = [
            {
              name      = data.terraform_remote_state.frontend.outputs.organizr.middlewares.auth_admin.name
              namespace = data.terraform_remote_state.frontend.outputs.organizr.middlewares.auth_admin.namespace
            }
          ]
        },
      ]
    }
  ]

  container_security_context = {
    privileged                 = true
    allow_privilege_escalation = true
  }

  host_directories = [
    {
      name       = "config"
      host_path  = format("%s/%s", var.directory_config.appdata, "scrutiny/config")
      mount_path = "/opt/scrutiny/config"
    },
    {
      name       = "influxdb"
      host_path  = format("%s/%s", var.directory_config.appdata, "scrutiny/influxdb")
      mount_path = "/opt/scrutiny/influxdb"
    },
  ]
}
