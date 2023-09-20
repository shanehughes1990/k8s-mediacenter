module "checkrr" {
  depends_on           = [kubernetes_namespace_v1.namespace]
  source               = "../../modules/deployment"
  name                 = "checkrr"
  namespace            = kubernetes_namespace_v1.namespace.metadata[0].name
  image_url            = "aetaric/checkrr"
  image_tag            = "latest"
  image_pull_policy    = "Always"
  metadata_annotations = local.keel_annotations
  args                 = ["-c", "/checkrr.yaml"]

  ports = [
    {
      name           = "app-port"
      container_port = 8585
      ingress = [
        {
          domain_match_pattern = "Host(`checkrr.${var.cloudflare_config.zone_name}`)"
          # domain_match_pattern = "Host(`checkrr.${var.cloudflare_config.zone_name}`) && PathPrefix(`/checkrr`)"
          middlewares = [
            {
              name      = data.terraform_remote_state.frontend.outputs.organizr.middlewares.auth_admin.name
              namespace = data.terraform_remote_state.frontend.outputs.organizr.middlewares.auth_admin.namespace
            }
          ]
        },
      ]
    }
  ]

  env = [
    {
      name      = "CONFIG_YAML"
      is_secret = true
      is_volume = {
        mount_path = "/checkrr.yaml"
        sub_path   = "checkrr.yaml"
      }
      value = yamlencode({
        "checkrr" : {
          "checkpath" : [
            "/data/media/movies",
            "/data/media/tvshows",
          ],
          "database" : "/config/checkrr.db",
          "debug" : true,
          "logfile" : "/config/checkrr.log",
          "logjson" : false,
          "cron" : "@daily",
          "ignorehidden" : true,
          "ignorepaths" : [
            "/tv/ignored"
          ],
          "ignoreexts" : [
            ".txt",
            ".nfo",
            ".nzb",
            ".url"
          ]
        },
        "webserver" : {
          "port" : 8585,
          "baseurl" : "/"
        },
        "arr" : {
          "radarr" : {
            "process" : true
            "service" : "radarr",
            "address" : "radarr-app-port.${kubernetes_namespace_v1.namespace.metadata[0].name}.svc",
            "apiKey" : "8263790f05c7463ea839f85c9eaee8c3"
            "baseurl" : "/radarr",
            "port" : 7878,
            "mappings" : {
              "/data/media/movies" : "/data/media/movies"
            }
          },
          "sonarr" : {
            "process" : true
            "service" : "sonarr",
            "address" : "sonarr-app-port.${kubernetes_namespace_v1.namespace.metadata[0].name}.svc",
            "apiKey" : "4739f1becadf4b60a3ad8e7c03647cad"
            "baseurl" : "/sonarr",
            "port" : 8989,
            "mappings" : {
              "/data/media/tvshows" : "/data/media/tvshows"
            }
          },
        },
      })
    },
  ]

  host_directories = [
    {
      name       = "config"
      host_path  = format("%s/%s", var.directory_config.appdata, "checkrr")
      mount_path = "/config"
    },
    {
      name       = "media"
      host_path  = var.directory_config.media
      mount_path = "/data/media"
    },
  ]
}
