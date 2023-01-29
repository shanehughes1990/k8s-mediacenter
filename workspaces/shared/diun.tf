locals {
  diun_deployment_name = "diun"
}

resource "kubernetes_service_account_v1" "diun" {
  automount_service_account_token = false
  metadata {
    name      = local.diun_deployment_name
    namespace = kubernetes_namespace_v1.namespace.metadata[0].name
  }
  secret {
    name = local.diun_deployment_name
  }
}

resource "kubernetes_secret_v1" "diun" {
  type = "kubernetes.io/service-account-token"
  metadata {
    name      = local.diun_deployment_name
    namespace = kubernetes_namespace_v1.namespace.metadata[0].name
    annotations = {
      "kubernetes.io/service-account.name"      = local.diun_deployment_name
      "kubernetes.io/service-account.namespace" = kubernetes_namespace_v1.namespace.metadata[0].name
    }
  }
}

resource "kubernetes_cluster_role_v1" "diun" {
  metadata {
    name = local.diun_deployment_name
  }

  rule {
    api_groups = [""]
    resources  = ["pods"]
    verbs      = ["get", "list", "watch"]
  }
}

resource "kubernetes_cluster_role_binding_v1" "diun" {
  metadata {
    name = local.diun_deployment_name
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role_v1.diun.metadata[0].name
  }
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account_v1.diun.metadata[0].name
    namespace = kubernetes_namespace_v1.namespace.metadata[0].name
  }
}

module "diun" {
  depends_on = [kubernetes_namespace_v1.namespace]
  source     = "../../modules/deployment"
  name       = local.diun_deployment_name
  namespace  = kubernetes_namespace_v1.namespace.metadata[0].name
  image_url  = "crazymax/diun"
  image_tag  = "latest"
  args       = ["serve"]

  service_account_name = local.diun_deployment_name

  deployment_annotations = {
    "diun.enable" = true
  }

  env = setunion(
    local.common_env,
    [
      {
        name  = "LOG_LEVEL"
        value = "info"
      },
      {
        name  = "LOG_JSON"
        value = false
      },
      {
        name  = "DIUN_WATCH_WORKERS"
        value = 20
      },
      {
        name  = "DIUN_WATCH_SCHEDULE"
        value = "0 */2 * * *"
      },
      {
        name  = "DIUN_WATCH_JITTER"
        value = "5s"
      },
      {
        name  = "DIUN_PROVIDERS_KUBERNETES"
        value = true
      },
      {
        name  = "DIUN_NOTIF_DISCORD_WEBHOOKURL"
        value = var.discord_webhook_url
      }
    ]
  )

  host_directories = [
    {
      name       = "data"
      host_path  = format("%s/%s", var.directory_config.appdata, "diun")
      mount_path = "/data"
    }
  ]
}
