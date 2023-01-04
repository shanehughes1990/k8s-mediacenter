locals {
  // take the absolute path of the current working dir and get just the folder name
  environment = element(split("/", path.cwd), length(split("/", path.cwd)) - 1)
}

terraform {
  required_version = ">= 1.0.0"
  backend "kubernetes" {
    secret_suffix = "frontend"
    namespace     = "kube-public"
    config_path   = "~/.kube/config"
  }

  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.16.1"
    }
  }
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}
