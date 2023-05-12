resource "kubernetes_manifest" "organizr_forward_auth_admin" {

  manifest = {
    "apiVersion" : "traefik.containo.us/v1alpha1",
    "kind" : "Middleware",
    "metadata" : {
      "name" : "organizr-forward-auth-admin"
      "namespace" : kubernetes_namespace_v1.namespace.metadata[0].name
    },
    "spec" : {
      "forwardAuth" : {
        "address" : "https://${var.cloudflare_config.zone_name}/api/v2/auth/$1"
      }
    }
  }
}

resource "kubernetes_manifest" "organizr_redirect_web_to_root" {

  manifest = {
    "apiVersion" : "traefik.containo.us/v1alpha1",
    "kind" : "Middleware",
    "metadata" : {
      "name" : "organizr-redirect-web-to-root"
      "namespace" : kubernetes_namespace_v1.namespace.metadata[0].name
    },
    "spec" : {
      "redirectRegex" : {
        "permanent" : true
        "regex" : "^https?://web.${var.cloudflare_config.zone_name}/(.*)"
        "replacement" : "https://${var.cloudflare_config.zone_name}/$${1}"
      }
    }
  }
}

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
          domain_match_pattern = "Host(`${var.cloudflare_config.zone_name}`)"
        },
        {
          domain_match_pattern = "Host(`web.${var.cloudflare_config.zone_name}`)"
          middlewares = [
            {
              name      = kubernetes_manifest.organizr_redirect_web_to_root.manifest.metadata.name
              namespace = kubernetes_manifest.organizr_redirect_web_to_root.manifest.metadata.namespace
            }
          ]
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
