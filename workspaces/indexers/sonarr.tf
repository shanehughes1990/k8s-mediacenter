module "sonarr_tvshows" {
  depends_on        = [kubernetes_namespace_v1.namespace]
  source            = "../../modules/deployment"
  name              = "sonarr-tvshows"
  namespace         = kubernetes_namespace_v1.namespace.metadata[0].name
  image_url         = "linuxserver/sonarr"
  image_tag         = "latest"
  image_pull_policy = "Always"

  ports = [
    {
      name           = "app-port"
      container_port = 8989
      ingress = [
        {
          domain_match_pattern = "Host(`${var.cloudflare_zone_name}`) && PathPrefix(`${var.sonarr_config.tvshows_instance.base_url}`)"
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

  env = concat(
    local.common_env,
    [
      {
        name  = "DOCKER_MODS"
        value = "gilbn/theme.park:sonarr"
      },
      {
        name  = "TP_THEME"
        value = "plex"
      },
      {
        name      = "CONFIG_XML"
        value     = <<-XML
          <Config>
            <LogLevel>info</LogLevel>
            <EnableSsl>False</EnableSsl>
            <Port>8989</Port>
            <SslPort>9898</SslPort>
            <UrlBase>${var.sonarr_config.tvshows_instance.base_url}</UrlBase>
            <BindAddress>*</BindAddress>
            <ApiKey>${var.sonarr_config.tvshows_instance.api_key}</ApiKey>
            <AuthenticationMethod>None</AuthenticationMethod>
            <UpdateMechanism>Docker</UpdateMechanism>
            <LaunchBrowser>True</LaunchBrowser>
            <Branch>main</Branch>
            <SslCertHash></SslCertHash>
            <InstanceName>Sonarr</InstanceName>
            <SyslogPort>514</SyslogPort>
          </Config>
        XML
        is_secret = true
        is_volume = {
          mount_path = "/config/config.xml"
          sub_path   = "config.xml"
        }
      }
    ]
  )

  host_directories = [
    {
      name       = "config"
      host_path  = format("%s/%s", var.directory_config.appdata, "sonarr-tvshows")
      mount_path = "/config"
    },
    {
      name       = "tvshows"
      host_path  = var.directory_config.tvshows
      mount_path = var.directory_config.tvshows
    },
  ]
}

module "sonarr_anime" {
  depends_on        = [kubernetes_namespace_v1.namespace]
  source            = "../../modules/deployment"
  name              = "sonarr-anime"
  namespace         = kubernetes_namespace_v1.namespace.metadata[0].name
  image_url         = "linuxserver/sonarr"
  image_tag         = "latest"
  image_pull_policy = "Always"

  ports = [
    {
      name           = "app-port"
      container_port = 8989
      ingress = [
        {
          domain_match_pattern = "Host(`${var.cloudflare_zone_name}`) && PathPrefix(`${var.sonarr_config.anime_instance.base_url}`)"
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

  env = concat(
    local.common_env,
    [
      {
        name  = "DOCKER_MODS"
        value = "gilbn/theme.park:sonarr"
      },
      {
        name  = "TP_THEME"
        value = "plex"
      },
      {
        name      = "CONFIG_XML"
        value     = <<-XML
          <Config>
            <LogLevel>info</LogLevel>
            <EnableSsl>False</EnableSsl>
            <Port>8989</Port>
            <SslPort>9898</SslPort>
            <UrlBase>${var.sonarr_config.anime_instance.base_url}</UrlBase>
            <BindAddress>*</BindAddress>
            <ApiKey>${var.sonarr_config.anime_instance.api_key}</ApiKey>
            <AuthenticationMethod>None</AuthenticationMethod>
            <UpdateMechanism>Docker</UpdateMechanism>
            <LaunchBrowser>True</LaunchBrowser>
            <Branch>main</Branch>
            <SslCertHash></SslCertHash>
            <InstanceName>Sonarr</InstanceName>
            <SyslogPort>514</SyslogPort>
          </Config>
        XML
        is_secret = true
        is_volume = {
          mount_path = "/config/config.xml"
          sub_path   = "config.xml"
        }
      }
    ]
  )

  host_directories = [
    {
      name       = "config"
      host_path  = format("%s/%s", var.directory_config.appdata, "sonarr-anime")
      mount_path = "/config"
    },
    {
      name       = "anime"
      host_path  = var.directory_config.anime
      mount_path = var.directory_config.anime
    },
  ]
}
