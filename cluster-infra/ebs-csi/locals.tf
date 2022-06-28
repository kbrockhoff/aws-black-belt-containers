locals {
  initial_storage_class_name = data.kubernetes_storage_class_v1.default.metadata[0].name
}
