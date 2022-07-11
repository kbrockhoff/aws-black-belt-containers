locals {
  node_group_name_prefix = "karpenter-${var.karpenter_provisioner_name}"
  azs_string             = "[\"${join("\", \"", var.availability_zones)}\"]"
  template_tags = {
    tags = var.addon_context.tags
  }
}
