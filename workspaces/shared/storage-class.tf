resource "kubernetes_storage_class_v1" "data_ssd" {
  metadata {
    name = "data-ssd-hostpath"
  }
  storage_provisioner = "microk8s.io/hostpath"
  reclaim_policy      = "Delete"
  volume_binding_mode = "WaitForFirstConsumer"
  parameters = {
    "pvDir" = "/data"
  }
}

resource "kubernetes_storage_class_v1" "local_storage" {
  metadata {
    name = "local-media-hostpath"
  }
  storage_provisioner = "microk8s.io/hostpath"
  reclaim_policy      = "Delete"
  volume_binding_mode = "WaitForFirstConsumer"
  parameters = {
    "pvDir" = "/local_media/pvc"
  }
}
