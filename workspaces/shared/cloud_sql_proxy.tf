module "cloud_sql_proxy" {
  depends_on           = [kubernetes_namespace_v1.namespace]
  source               = "../../modules/deployment"
  name                 = "cloud-sql-proxy"
  namespace            = kubernetes_namespace_v1.namespace.metadata[0].name
  image_url            = "gcr.io/cloud-sql-connectors/cloud-sql-proxy"
  image_tag            = "2.8.2"
  metadata_annotations = local.keel_annotations
  args                 = setunion(var.cloud_sql_proxy_config.instances, ["--address=0.0.0.0"])

  ports = [
    {
      name           = "mysql-port"
      service_type   = "NodePort"
      container_port = 3306
      node_port      = 30001
    },
    {
      name           = "postgres-port"
      service_type   = "NodePort"
      container_port = 5432
      node_port      = 30002
    }
  ]

  env = [
    {
      name  = "GOOGLE_APPLICATION_CREDENTIALS"
      value = "/credentials.json"
    },
    {
      name      = "GOOGLE_APPLICATION_SECRET"
      value     = base64decode(var.cloud_sql_proxy_config.base64_encoded_application_credentials)
      is_secret = true
      is_volume = {
        mount_path = "/credentials.json"
        sub_path   = "credentials.json"
      }
    },
  ]
}
