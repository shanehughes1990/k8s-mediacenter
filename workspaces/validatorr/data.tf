data "terraform_remote_state" "frontend" {
  backend = "kubernetes"

  config = {
    secret_suffix = "frontend"
    namespace     = "kube-public"
    config_path   = "~/.kube/config"
  }
}
