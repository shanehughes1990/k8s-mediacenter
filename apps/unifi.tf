resource "cloudflare_record" "unifi" {
  type    = "CNAME"
  zone_id = var.cloudflare_config.zone_id
  value   = var.cloudflare_config.zone_name
  name    = format("%s.%s", "unifi", var.cloudflare_config.zone_name)
}

resource "kubernetes_service_v1" "unifi_tb" {
  for_each = {
    for s in [
      {
        name     = "unifi-lb-tcp"
        protocol = "TCP"
        ports = [
          {
            name           = "app-port"
            container_port = 8443
          },
          {
            name           = "comm-port"
            container_port = 8080
          },
        ]
      },
      {
        name     = "unifi-lb-udp"
        protocol = "UDP"
        ports = [
          {
            name           = "stun-port"
            container_port = 3478
          },
          {
            name           = "discovery-port"
            container_port = 10001
          },
        ]
      },
    ] : s.name => s
  }

  metadata {
    name      = each.value.name
    namespace = kubernetes_namespace_v1.namespace.metadata[0].name
    annotations = {
      "metallb.universe.tf/allow-shared-ip" = true
    }
  }

  spec {
    type             = "LoadBalancer"
    load_balancer_ip = "192.168.0.249"
    selector = {
      app = "unifi"
    }

    dynamic "port" {
      for_each = each.value.ports
      content {
        name        = port.value.name
        target_port = port.value.name
        port        = port.value.container_port
        protocol    = each.value.protocol
      }
    }
  }
}

module "unifi" {
  depends_on = [kubernetes_namespace_v1.namespace]
  source     = "../../modules/deployment"
  name       = "unifi"
  namespace  = kubernetes_namespace_v1.namespace.metadata[0].name
  image_url  = "lscr.io/linuxserver/unifi-controller"
  image_tag  = "latest"

  deployment_annotations = {
    "diun.enable" = true
  }

  ports = [
    {
      name           = "app-port"
      container_port = 8443
      is_ingress = {
        tls_cluster_issuer = local.tls_cluster_issuer
        additional_annotations = {
          "nginx.ingress.kubernetes.io/backend-protocol" = "HTTPS"
        }
        domains = [
          {
            name = cloudflare_record.unifi.name
          },
        ]
      }
    },
    {
      name           = "stun-port"
      container_port = 3478
      protocol       = "UDP"
    },
    {
      name           = "discovery-port"
      container_port = 10001
      protocol       = "UDP"
    },
    {
      name           = "comm-port"
      container_port = 8080
    },
  ]

  env = local.common_env

  host_directories = [
    {
      name       = "config"
      host_path  = format("%s/%s", var.directory_config.appdata, "unifi")
      mount_path = "/config"
    }
  ]
}
