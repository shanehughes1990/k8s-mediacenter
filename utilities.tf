locals {
  cloudflare_ddns = {
    name      = "cloudflare-ddns"
    image_url = "cr.hotio.dev/hotio/cloudflareddns"
    image_tag = "latest"
  }
  cloud_sql_proxy = {
    name      = "cloud-sql-proxy"
    image_url = "gcr.io/cloud-sql-connectors/cloud-sql-proxy"
    image_tag = "2.0.0-preview.3"
  }
  minecraft_router = {
    name      = "minecraft-router"
    image_url = "itzg/mc-router"
    image_tag = "1.16.1"
  }
}

module "cloudflare_ddns" {
  depends_on = [kubernetes_namespace_v1.namespace]
  source     = "./modules/deployment"
  name       = local.cloudflare_ddns.name
  namespace  = kubernetes_namespace_v1.namespace[local.namespaces[1]].metadata[0].name

  containers = [{
    name      = local.cloudflare_ddns.name
    image_url = local.cloudflare_ddns.image_url
    image_tag = local.cloudflare_ddns.image_tag

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
          value = 3
        },
        {
          name  = "CF_RECORDTYPES"
          value = "A"
        },
      ]
    )

    env_secrets = [
      {
        name  = "CF_APITOKEN"
        value = var.provider_config.cloudflare.api_token
      },
      {
        name  = "CF_HOSTS"
        value = var.provider_config.cloudflare.zone_name
      },
      {
        name  = "CF_ZONES"
        value = var.provider_config.cloudflare.zone_name
      },
    ]
  }]
}

# TODO: finish configuring this
# module "cloud_sql_proxy" {
#   depends_on = [kubernetes_namespace_v1.namespace]
#   source     = "./modules/deployment"
#   name       = local.cloud_sql_proxy.name
#   namespace  = kubernetes_namespace_v1.namespace[local.namespaces[1]].metadata[0].name

#   containers = [{
#     name      = local.cloud_sql_proxy.name
#     image_url = local.cloud_sql_proxy.image_url
#     image_tag = local.cloud_sql_proxy.image_tag
#     args      = setunion(var.cloud_sql_proxy_config.instances, ["--address=0.0.0.0"])

#     ports = [{
#       name           = "proxy-port"
#       service_type   = "NodePort"
#       container_port = 3306
#       node_port      = 30001
#     }]

#     ports = [{
#       name           = "proxy-port"
#       service_type   = "NodePort"
#       container_port = 3307
#       node_port      = 30002
#     }]

#     env = [{
#       name  = "GOOGLE_APPLICATION_CREDENTIALS"
#       value = "/credentials.json"
#     }]

#     env_secrets = [
#       {
#         name  = "GOOGLE_APPLICATION_CREDENTIALS"
#         value = base64decode(var.cloud_sql_proxy_config.base64_encoded_application_credentials)
#         is_volume = {
#           mount_path = "/credentials.json"
#           sub_path   = "credentials.json"
#         }
#       },
#     ]
#   }]
# }

# TODO: finish configuring this
# module "minecraft_router" {
#   depends_on = [kubernetes_namespace_v1.namespace]
#   source     = "./modules/deployment"
#   name       = local.minecraft_router.name
#   namespace  = kubernetes_namespace_v1.namespace[local.namespaces[1]].metadata[0].name

#   containers = [{
#     name      = local.minecraft_router.name
#     image_url = local.minecraft_router.image_url
#     image_tag = local.minecraft_router.image_tag

#     ports = [{
#       name           = "minecraft-port"
#       container_port = 25565
#     }]

#     env = [
#       {
#         name  = "MAPPING"
#         value = ""
#       },
#       {
#         name  = "DEBUG"
#         value = true
#       },
#     ]
#   }]
# }
