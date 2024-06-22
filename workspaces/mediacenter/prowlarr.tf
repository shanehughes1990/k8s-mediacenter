module "prowlarr" {
  depends_on           = [kubernetes_namespace_v1.namespace]
  source               = "../../modules/deployment"
  name                 = "prowlarr"
  namespace            = kubernetes_namespace_v1.namespace.metadata[0].name
  image_url            = "lscr.io/linuxserver/prowlarr"
  image_tag            = "latest"
  metadata_annotations = local.keel_annotations
  replicas             = 0

  ports = [
    {
      name           = "app-port"
      container_port = 9696
      ingress = [
        {
          domain_match_pattern = "Host(`${var.cloudflare_config.zone_name}`) && PathPrefix(`${var.prowlarr_config.base_url}`)"
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
        value = "gilbn/theme.park:prowlarr"
      },
      {
        name  = "TP_THEME"
        value = "plex"
      },
      {
        name      = "CONFIG_XML"
        value     = <<-XML
          <Config>
            <BindAddress>*</BindAddress>
            <Port>9696</Port>
            <SslPort>6969</SslPort>
            <EnableSsl>False</EnableSsl>
            <LaunchBrowser>True</LaunchBrowser>
            <ApiKey>${var.prowlarr_config.api_key}</ApiKey>
            <AuthenticationMethod>Forms</AuthenticationMethod>
            <AuthenticationRequired>DisabledForLocalAddresses</AuthenticationRequired>
            <Branch>master</Branch>
            <LogLevel>info</LogLevel>
            <SslCertPath></SslCertPath>
            <SslCertPassword></SslCertPassword>
            <UrlBase>${var.prowlarr_config.base_url}</UrlBase>
            <InstanceName>Prowlarr</InstanceName>
            <UpdateMechanism>Docker</UpdateMechanism>
          </Config>
        XML
        is_secret = true
        is_volume = {
          mount_path = "/config/config.xml"
          sub_path   = "config.xml"
        }
      }
    ],
  )

  host_directories = [
    {
      name       = "config"
      host_path  = format("%s/%s", var.directory_config.appdata, "prowlarr")
      mount_path = "/config"
    },
  ]
}
