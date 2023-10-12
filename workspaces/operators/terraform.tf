locals {
  // take the absolute path of the current working dir and get just the folder name
  environment = element(split("/", path.cwd), length(split("/", path.cwd)) - 1)
}

terraform {
  required_version = ">= 1.0.0"
  backend "kubernetes" {
    secret_suffix = "operators"
    namespace     = "kube-public"
    config_path   = "~/.kube/config"
  }

  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.16.1"
    }

    helm = {
      source  = "hashicorp/helm"
      version = "2.11.0"
    }

    kubectl = {
      source  = "cpanato/kubectl"
      version = "1.14.1"
    }
  }
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}

provider "kubectl" {
  config_path = "~/.kube/config"
}
