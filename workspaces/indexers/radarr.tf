module "radarr_main" {
  depends_on        = [kubernetes_namespace_v1.namespace]
  source            = "../../modules/deployment"
  name              = "radarr-main"
  namespace         = kubernetes_namespace_v1.namespace.metadata[0].name
  image_url         = "linuxserver/radarr"
  image_tag         = "latest"
  image_pull_policy = "Always"

  ports = [
    {
      name           = "app-port"
      container_port = 7878
      ingress = [
        {
          domain_match_pattern = "Host(`${var.cloudflare_zone_name}`) && PathPrefix(`${var.radarr_config.main_instance.base_url}`)"
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
        value = "gilbn/theme.park:radarr"
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
            <UrlBase>${var.radarr_config.main_instance.base_url}</UrlBase>
            <UpdateMechanism>Docker</UpdateMechanism>
            <BindAddress>*</BindAddress>
            <Port>7878</Port>
            <SslPort>9898</SslPort>
            <EnableSsl>False</EnableSsl>
            <LaunchBrowser>True</LaunchBrowser>
            <ApiKey>${var.radarr_config.main_instance.api_key}</ApiKey>
            <AuthenticationMethod>Forms</AuthenticationMethod>
            <Branch>develop</Branch>
            <SslCertPath></SslCertPath>
            <SslCertPassword></SslCertPassword>
            <InstanceName>Radarr</InstanceName>
            <AuthenticationRequired>DisabledForLocalAddresses</AuthenticationRequired>
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
      host_path  = format("%s/%s", var.directory_config.appdata, "radarr-main")
      mount_path = "/config"
    },
    {
      name       = "movies"
      host_path  = var.directory_config.movies
      mount_path = var.directory_config.movies
    },
  ]
}