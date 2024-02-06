output "postgres" {
  sensitive = true
  value = {
    username = var.postgres_config.username
    password = var.postgres_config.password
    svc      = "postgres-sql-port.${kubernetes_namespace_v1.namespace.metadata[0].name}.svc"
  }
}
