module "plex" {
  depends_on = [kubernetes_namespace_v1.namespace]
  source     = "../../modules/deployment"
  name       = "plex"
  namespace  = kubernetes_namespace_v1.namespace.metadata[0].name
  image_url  = "plexinc/pms-docker"
  image_tag  = "1.40.0.7998-c29d4c0c8"
  # image_tag            = "1.41.6.9685-d301f511a" // Error: Unable to set up server: sqlite3_statement_backend::loadOne: database disk image is malformed (N4soci10soci_errorE)
  metadata_annotations = local.keel_annotations

  resources = {
    limits = {
      memory = "24Gi"
    }
  }
  readiness_probe = {
    initial_delay_seconds = 5
    period_seconds        = 10
    success_threshold     = 1
    timeout_seconds       = 3

    http_get = {
      path = "/identity"
      port = 32400
    }
  }

  # liveness_probe = {
  #   initial_delay_seconds = 2
  #   period_seconds        = 10
  #   success_threshold     = 1
  #   timeout_seconds       = 3

  #   http_get = {
  #     path = "/identity"
  #     port = 32400
  #   }
  # }

  ports = [
    {
      name           = "app-port"
      service_type   = "NodePort"
      container_port = 32400
      node_port      = 32400
      cluster_ip     = "10.152.183.36"
      ingress = [
        {
          domain_match_pattern = "Host(`${var.cloudflare_config.zone_name}`) && PathPrefix(`/web`)"
        },
      ]
    }
  ]

  env = setunion(
    local.common_env,
    [
      {
        name  = "VERSION"
        value = "docker"
      },
      {
        name  = "NVIDIA_VISIBLE_DEVICES"
        value = "all"
      },
      {
        name  = "NVIDIA_DRIVER_CAPABILITIES"
        value = "compute,video,utility"
      },
      {
        name      = "PLEX_CLAIM"
        value     = var.plex_claim
        is_secret = true
      },
    ]
  )

  host_directories = [
    {
      name       = "config"
      host_path  = format("%s/%s", var.directory_config.appdata, "plex")
      mount_path = "/config"
    },
    {
      name       = "media"
      host_path  = var.directory_config.media
      mount_path = "/data/media"
    },
  ]

  ram_disks = [
    {
      name       = "transcoding"
      mount_path = "/transcode"
      size_limit = "24Gi"
    }
  ]
}
