resource "kubernetes_manifest" "signoz" {
  manifest = {
    "apiVersion" : "traefik.containo.us/v1alpha1",
    "kind" : "IngressRoute",
    "metadata" : {
      "name" : "signoz-frontend"
      "namespace" : kubernetes_namespace_v1.namespace.metadata[0].name
      "annotations" = merge(
        {
          "kubernetes.io/ingress.class" : "traefik"
          "ingress.kubernetes.io/ssl-redirect" : true
        },
      )
    },
    "spec" : {
      "entryPoints" : ["websecure"],
      "routes" : [
        {
          "match" : "Host(`metrics.${var.cloudflare_config.zone_name}`)",
          "kind" : "Rule",
          "services" : [
            {
              "kind" : "Service"
              "name" = "signoz-frontend"
              "namespace" : kubernetes_namespace_v1.namespace.metadata[0].name
              "port" : 3301
            }
          ]
        }
      ],
    }
  }
}

resource "helm_release" "signoz" {
  depends_on = [kubernetes_namespace_v1.namespace]
  namespace  = kubernetes_namespace_v1.namespace.metadata[0].name
  repository = "https://charts.signoz.io"
  chart      = "signoz"
  version    = "0.54.2"
  name       = "signoz"
  wait       = false

  values = [
    yamlencode(
      {
        "global" : {
          "clusterName" : "microk8s",
          "storageClass" : "data-ssd-hostpath",
          "cloud" : "other",
        },
        "otelCollector" : {
          "service" : {
            "type" : "NodePort"
          },
        },
      }
    ),
  ]
}

resource "helm_release" "signoz-k8s-infra" {
  depends_on = [kubernetes_namespace_v1.namespace]
  namespace  = kubernetes_namespace_v1.namespace.metadata[0].name
  repository = "https://charts.signoz.io"
  chart      = "k8s-infra"
  version    = "0.11.18"
  name       = "k8s-infra"

  values = [
    yamlencode(
      {
        "global" : {
          "clusterName" : "microk8s",
          "storageClass" : "data-ssd-hostpath",
          "cloud" : "other",
        },
        "otelCollectorEndpoint" : "signoz-otel-collector.${kubernetes_namespace_v1.namespace.metadata[0].name}.svc:4317",
        "otelInsecure" : true,
      }
    ),
  ]
}
