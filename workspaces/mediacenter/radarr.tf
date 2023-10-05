module "radarr" {
  depends_on           = [kubernetes_namespace_v1.namespace]
  source               = "../../modules/deployment"
  name                 = "radarr"
  namespace            = kubernetes_namespace_v1.namespace.metadata[0].name
  image_url            = "linuxserver/radarr"
  image_tag            = "develop"
  image_pull_policy    = "Always"
  metadata_annotations = local.keel_annotations

  ports = [
    {
      name           = "app-port"
      container_port = 7878
      ingress = [
        {
          domain_match_pattern = "Host(`${var.cloudflare_config.zone_name}`) && PathPrefix(`/radarr`)"
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
            <UrlBase>/radarr</UrlBase>
            <UpdateMechanism>Docker</UpdateMechanism>
            <BindAddress>*</BindAddress>
            <Port>7878</Port>
            <SslPort>9898</SslPort>
            <EnableSsl>False</EnableSsl>
            <LaunchBrowser>True</LaunchBrowser>
            <ApiKey>${var.radarr_api_key}</ApiKey>
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
      host_path  = format("%s/%s", var.directory_config.appdata, "radarr")
      mount_path = "/config"
    },
    {
      name       = "movies"
      host_path  = var.directory_config.movies
      mount_path = "/data/media/movies"
    },
    {
      name       = "downloads"
      host_path  = format("%s/usenet", var.directory_config.downloads)
      mount_path = "/data/downloads"
    },
  ]
}
