locals {
  kubernetes_dashboard_name = "kubernetes-dashboard"
  kubernetes_dashboard_secrets = {
    csrf       = format("%s-csrf", local.kubernetes_dashboard_name)
    certs      = format("%s-certs", local.kubernetes_dashboard_name)
    key_holder = format("%s-key-holder", local.kubernetes_dashboard_name)
  }
}

resource "cloudflare_record" "kubernetes_dashboard" {
  type    = "CNAME"
  zone_id = var.cloudflare_config.zone_id
  value   = var.cloudflare_config.zone_name
  name    = format("%s.%s", "k8s", var.cloudflare_config.zone_name)
}

resource "kubernetes_service_account_v1" "kubernetes_dashboard" {
  depends_on = [
    kubernetes_namespace_v1.namespace,
  ]

  metadata {
    name      = local.kubernetes_dashboard_name
    namespace = kubernetes_namespace_v1.namespace.metadata[0].name
  }
}

resource "kubernetes_secret_v1" "kubernetes_dashboard" {
  for_each = {
    for s in [
      {
        name = local.kubernetes_dashboard_secrets.csrf
        data = {
          csrf = ""
        }
      },
      {
        name = local.kubernetes_dashboard_secrets.certs
        data = null
      },
      {
        name = local.kubernetes_dashboard_secrets.key_holder
        data = null
      },
    ] : s.name => s
  }

  metadata {
    name      = each.value.name
    namespace = kubernetes_namespace_v1.namespace.metadata[0].name
  }

  data = each.value.data
}

resource "kubernetes_config_map_v1" "kubernetes_dashboard" {
  metadata {
    name      = format("%s-settings", local.kubernetes_dashboard_name)
    namespace = kubernetes_namespace_v1.namespace.metadata[0].name
  }
}

resource "kubernetes_role_v1" "kubernetes_dashboard" {
  metadata {
    name      = local.kubernetes_dashboard_name
    namespace = kubernetes_namespace_v1.namespace.metadata[0].name
  }

  dynamic "rule" {
    for_each = [
      {
        verbs      = ["get", "update", "delete"]
        api_groups = [""]
        resources  = ["secrets"]
        resource_names = [
          local.kubernetes_dashboard_secrets.key_holder,
          local.kubernetes_dashboard_secrets.certs,
          local.kubernetes_dashboard_secrets.csrf,
        ]
      },
      {
        verbs      = ["get", "update"]
        api_groups = [""]
        resources  = ["configmaps"]
        resource_names = [
          kubernetes_config_map_v1.kubernetes_dashboard.metadata[0].name,
        ]
      },
      {
        verbs      = ["proxy"]
        api_groups = [""]
        resources  = ["services"]
        resource_names = [
          "heapster",
          "dashboard-metrics-scraper",
        ]
      },
      {
        verbs      = ["get"]
        api_groups = [""]
        resources  = ["services/proxy"]
        resource_names = [
          "heapster",
          "http:heapster:",
          "https:heapster:",
          "dashboard-metrics-scraper",
          "http:dashboard-metrics-scraper",
        ]
      },
    ]

    content {
      verbs          = rule.value.verbs
      api_groups     = rule.value.api_groups
      resources      = rule.value.resources
      resource_names = rule.value.resource_names
    }
  }
}

resource "kubernetes_role_binding_v1" "kubernetes_dashboard" {
  depends_on = [
    kubernetes_service_account_v1.kubernetes_dashboard,
    kubernetes_role_v1.kubernetes_dashboard,
  ]

  metadata {
    name      = local.kubernetes_dashboard_name
    namespace = kubernetes_namespace_v1.namespace.metadata[0].name
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account_v1.kubernetes_dashboard.metadata[0].name
    namespace = kubernetes_namespace_v1.namespace.metadata[0].name
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role_v1.kubernetes_dashboard.metadata[0].name
  }
}

resource "kubernetes_cluster_role_v1" "kubernetes_dashboard" {
  metadata {
    name = local.kubernetes_dashboard_name
  }

  rule {
    verbs      = ["get", "list", "watch"]
    api_groups = ["metrics.k8s.io"]
    resources  = ["pods", "nodes"]
  }
}

resource "kubernetes_cluster_role_binding_v1" "kubernetes_dashboard" {
  depends_on = [
    kubernetes_service_account_v1.kubernetes_dashboard,
    kubernetes_cluster_role_v1.kubernetes_dashboard,
  ]

  metadata {
    name = local.kubernetes_dashboard_name
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account_v1.kubernetes_dashboard.metadata[0].name
    namespace = kubernetes_namespace_v1.namespace.metadata[0].name
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role_v1.kubernetes_dashboard.metadata[0].name
  }
}

module "kubernetes_dashboard" {
  depends_on = [
    kubernetes_namespace_v1.namespace,
    kubernetes_role_binding_v1.kubernetes_dashboard,
    kubernetes_cluster_role_binding_v1.kubernetes_dashboard,
  ]

  source               = "../../modules/deployment"
  name                 = "kubernetes-dashboard"
  namespace            = kubernetes_namespace_v1.namespace.metadata[0].name
  image_url            = "kubernetesui/dashboard"
  image_tag            = "v2.7.0"
  metadata_annotations = local.keel_annotations
  service_account_name = kubernetes_service_account_v1.kubernetes_dashboard.metadata[0].name

  args = [
    "--enable-skip-login",
    "--disable-settings-authorizer",
    "--enable-insecure-login",
    "--namespace=${kubernetes_namespace_v1.namespace.metadata[0].name}",
  ]

  ports = [
    {
      name           = "app-port"
      container_port = 9090
      ingress = [
        {
          tls_cluster_issuer = local.tls_cluster_issuer
          additional_annotations = {
            "nginx.ingress.kubernetes.io/auth-url" = "https://${cloudflare_record.organizr.name}/api/v2/auth/$1"
          }
          domains = [
            {
              name = cloudflare_record.kubernetes_dashboard.name
            },
          ]
        },
      ]
    },
  ]

  tmp_disks = [
    # Create on-disk volume to store exec logs
    {
      name       = "tmp"
      mount_path = "/tmp"
    }
  ]
}
