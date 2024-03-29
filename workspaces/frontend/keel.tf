locals {
  keel_deployment_name = "keel"
}

resource "kubernetes_service_account_v1" "keel" {
  automount_service_account_token = false
  metadata {
    name      = local.keel_deployment_name
    namespace = kubernetes_namespace_v1.namespace.metadata[0].name
  }
}

resource "kubernetes_cluster_role_v1" "keel" {
  metadata {
    name = local.keel_deployment_name
  }

  dynamic "rule" {
    for_each = [
      {
        api_groups = [""]
        resources  = ["namespaces"]
        verbs      = ["watch", "list"]
      },
      {
        api_groups = [""]
        resources  = ["secrets"]
        verbs      = ["get", "watch", "list"]
      },
      {
        api_groups = ["", "extensions", "apps", "batch"]
        resources = [
          "pods",
          "replicasets",
          "replicationcontrollers",
          "statefulsets",
          "deployments",
          "daemonsets",
          "jobs",
          "cronjobs",
        ]
        verbs = ["get", "delete", "watch", "list", "update"]
      },
      {
        api_groups = [""]
        resources  = ["configmaps", "pods/portforward"]
        verbs      = ["get", "create", "update"]
      },
    ]

    content {
      api_groups = rule.value.api_groups
      resources  = rule.value.resources
      verbs      = rule.value.verbs
    }
  }

}

resource "kubernetes_cluster_role_binding_v1" "keel" {
  metadata {
    name = local.keel_deployment_name
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role_v1.keel.metadata[0].name
  }
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account_v1.keel.metadata[0].name
    namespace = kubernetes_namespace_v1.namespace.metadata[0].name
  }
}

module "keel" {
  depends_on = [kubernetes_namespace_v1.namespace]
  source     = "../../modules/deployment"
  name       = local.keel_deployment_name
  namespace  = kubernetes_namespace_v1.namespace.metadata[0].name
  image_url  = "keelhq/keel"
  image_tag  = "latest"
  command    = ["/bin/keel"]

  ports = [
    {
      name           = "app-port"
      container_port = 9300
      ingress = [
        {
          domain_match_pattern = "Host(`keel.${var.cloudflare_config.zone_name}`)"
          middlewares = [
            {
              name      = kubernetes_manifest.organizr_forward_auth_admin.manifest.metadata.name
              namespace = kubernetes_manifest.organizr_forward_auth_admin.manifest.metadata.namespace
            }
          ]
        },
      ]
    }
  ]

  env = [
    {
      name  = "NAMESPACE"
      value = kubernetes_namespace_v1.namespace.metadata[0].name
    },
    {
      name  = "NOTIFICATION_LEVEL"
      value = "debug"
    },
    {
      name  = "WEBHOOK_ENDPOINT"
      value = var.discord_webhook_url
    },
    {
      name  = "BASIC_AUTH_USER"
      value = var.keel_config.username
    },
    {
      name  = "BASIC_AUTH_PASSWORD"
      value = var.keel_config.password
    },
  ]

  host_directories = [
    {
      name       = "data"
      mount_path = "/data"
      host_path  = format("%s/%s", var.directory_config.appdata, "keel")
    }
  ]
}
