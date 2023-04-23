module "organizr" {
  depends_on           = [kubernetes_namespace_v1.namespace]
  source               = "../../modules/deployment"
  name                 = "organizr"
  namespace            = kubernetes_namespace_v1.namespace.metadata[0].name
  image_url            = "organizr/organizr"
  image_tag            = "latest"
  metadata_annotations = local.keel_annotations

  ports = [
    {
      name           = "app-port"
      container_port = 80
      ingress = [
        {
          domain_match_pattern = "Host(`web.${var.cloudflare_config.zone_name}`)"
          # additional_annotations = {
          #   "ingress.kubernetes.io/preserve-host" : true
          #   # Forces a Permanent (301) redirect
          #   "ingress.kubernetes.io/redirect-permanent" : true
          #   # Specifies a regex for which URLs to redirect
          #   "ingress.kubernetes.io/redirect-regex" : "^https://web.${var.cloudflare_config.zone_name}/(.*)"
          #   # Here is where redirected URLs will end up
          #   #   Notice the $3, which is the third capture
          #   #   group from the above regex
          #   "ingress.kubernetes.io/redirect-replacement" : "https://${var.cloudflare_config.zone_name}/$1"
          # }
        },
      ]
    },
  ]

  env = setunion(
    local.common_env,
    [
      {
        name  = "branch"
        value = "v2-master"
      },
      {
        name  = "fpm"
        value = false
      },
    ]
  )

  host_directories = [
    {
      name       = "config"
      host_path  = format("%s/%s", var.directory_config.appdata, "organizr")
      mount_path = "/config"
    }
  ]
}
