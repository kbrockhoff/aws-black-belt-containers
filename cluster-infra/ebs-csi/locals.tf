locals {
  initial_storage_class_name = data.kubernetes_storage_class_v1.default.metadata[0].name

  kubeconfig_options = length(var.kubeconfig_file) > 0 && length(var.kubeconfig_name) > 0 ? (
    "--kubeconfig=${var.kubeconfig_file} --context=${var.kubeconfig_name}"
    ) : (
    ""
  )
}
