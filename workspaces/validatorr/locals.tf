locals {
  image_name    = "ghcr.io/hyperdxio/hyperdx"
  image_version = "0.10.0"

  hyperdx_api_key             = ""
  log_level                   = "debug"
  otel_exporter_otlp_endpoint = "http://otel-collector:4318"
  go_parser = {
    name = "go-parser"
    port = {
      name           = "app-port"
      container_port = 7777
    }
  }
  miner = {
    name = "miner"
    port = {
      name           = "app-port"
      container_port = 5123
    }
  }
  hostmetrics = {
    name = "hostmetrics"
  }
  ingestor = {
    name = "ingestor"
    port = {
      name           = "http-generic"
      container_port = 8002
    }
  }
  aggregator = {
    name = "aggregator"
    port = {
      name           = "app-port"
      container_port = 8001
    }
  }

  env = {
    aggregator_api_url = {
      name  = "AGGREGATOR_API_URL"
      value = "http://${local.aggregator.name}-${local.aggregator.port.name}.${local.environment}.svc:${local.aggregator.port.container_port}"
    }
    hyperdx_api_key = {
      name  = "HYPERDX_API_KEY"
      value = local.hyperdx_api_key
    }
    hyperdx_log_level = {
      name  = "HYPERDX_LOG_LEVEL"
      value = local.log_level
    }
    otel_exporter_otlp_endpoint = {
      name  = "OTEL_EXPORTER_OTLP_ENDPOINT"
      value = local.otel_exporter_otlp_endpoint
    }
    otel_log_level = {
      name  = "OTEL_LOG_LEVEL"
      value = local.log_level
    }
    otel_service_name = {
      name  = "OTEL_SERVICE_NAME"
      value = ""
    }
  }

  common_env = [
    {
      name  = "HYPERDX_API_KEY"
      value = ""
    },
  ]

  keel_annotations = {
    "keel.sh/policy"       = "force"
    "keel.sh/pollSchedule" = "@every 10m"
    "keel.sh/trigger"      = "poll"
  }
}
