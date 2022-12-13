terraform {
  required_version = ">= 1.0.0"
  backend "kubernetes" {
    secret_suffix = "state"
    namespace     = "kube-system"
    config_path   = "~/.kube/config"
  }

  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.16.1"
    }

    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "1.14.0"
    }

    helm = {
      source  = "hashicorp/helm"
      version = "2.7.1"
    }

    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "3.29.0"
    }
  }
}

provider "kubernetes" {
  host                   = var.provider_config.kubernetes.host
  token                  = var.provider_config.kubernetes.token
  cluster_ca_certificate = base64decode(var.provider_config.kubernetes.cluster_ca_certificate)
}

provider "kubectl" {
  load_config_file       = false
  host                   = var.provider_config.kubernetes.host
  token                  = var.provider_config.kubernetes.token
  cluster_ca_certificate = base64decode(var.provider_config.kubernetes.cluster_ca_certificate)
}

provider "helm" {
  kubernetes {
    host                   = var.provider_config.kubernetes.host
    token                  = var.provider_config.kubernetes.token
    cluster_ca_certificate = base64decode(var.provider_config.kubernetes.cluster_ca_certificate)
  }
}

provider "cloudflare" {
  api_token = var.provider_config.cloudflare.api_token
}
