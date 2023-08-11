locals {
  // take the absolute path of the current working dir and get just the folder name
  environment = element(split("/", path.cwd), length(split("/", path.cwd)) - 1)
}

terraform {
  required_version = ">= 1.0.0"
  backend "kubernetes" {
    secret_suffix = "immich"
    namespace     = "kube-public"
    config_path   = "~/.kube/config"
  }

  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.16.1"
    }

    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "3.29.0"
    }

    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "1.14.0"
    }
  }
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}

provider "cloudflare" {
  api_token = var.cloudflare_config.api_token
}

provider "kubectl" {
  config_path = "~/.kube/config"
}
