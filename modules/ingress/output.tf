output "tls_production_issuer" {
  value = local.cluster_issuer[0].name
}

output "tls_staging_issuer" {
  value = local.cluster_issuer[1].name
}
