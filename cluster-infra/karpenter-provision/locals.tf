locals {
  node_group_name_prefix = "${var.addon_context.eks_cluster_id}-karpenter-${var.karpenter_provisioner_name}"
}
