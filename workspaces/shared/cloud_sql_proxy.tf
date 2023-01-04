module "cloud_sql_proxy" {
  depends_on = [kubernetes_namespace_v1.namespace]
  source     = "../../modules/deployment"
  name       = "cloud-sql-proxy"
  namespace  = kubernetes_namespace_v1.namespace.metadata[0].name

  containers = [{
    name      = "cloud-sql-proxy"
    image_url = "gcr.io/cloud-sql-connectors/cloud-sql-proxy"
    image_tag = "2.0.0-preview.3"
    args      = setunion(var.cloud_sql_proxy_config.instances, ["--address=0.0.0.0"])

    ports = [{
      name           = "proxy-port"
      service_type   = "NodePort"
      container_port = 3306
      node_port      = 30001
    }]

    env = [{
      name  = "GOOGLE_APPLICATION_CREDENTIALS"
      value = "/credentials.json"
    }]

    env_secrets = [
      {
        name  = "GOOGLE_APPLICATION_CREDENTIALS"
        value = base64decode(var.cloud_sql_proxy_config.base64_encoded_application_credentials)
        is_volume = {
          mount_path = "/credentials.json"
          sub_path   = "credentials.json"
        }
      },
    ]
  }]
}
