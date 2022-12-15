terraform {
  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
    }

    cloudflare = {
      source = "cloudflare/cloudflare"
    }
  }
}
