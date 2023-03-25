data "terraform_remote_state" "shared" {
  backend = "kubernetes"

  config = {
    secret_suffix = "shared"
    namespace     = "kube-public"
    config_path   = "~/.kube/config"
  }
}
