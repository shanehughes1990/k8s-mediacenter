resource "helm_release" "keel" {
  namespace  = "kube-system"
  repository = "https://charts.keel.sh"
  chart      = "keel"
  name       = "keel"
  version    = "1.0.3"

  values = [
    yamlencode(
      {
        "keel" : {
          "policy" : "patch",
          "trigger" : "poll",
          "pollSchedule" : "@every 3m",
          "images" : [
            {
              "repository" : "image.repository",
              "tag" : "image.tag"
            }
          ],
        },
        "helmProvider" : {
          "enabled" : false,
          "version" : "v3"
        },
        "discord" : {
          "enabled" : true,
          "webhookUrl" : var.discord_webhook_url
        },
      }
    )
  ]
}
