variable "addon_context" {
  description = "Input configuration for the addon"
  type = object({
    aws_caller_identity_account_id = string
    aws_caller_identity_arn        = string
    aws_eks_cluster_endpoint       = string
    aws_partition_id               = string
    aws_region_name                = string
    eks_cluster_id                 = string
    eks_oidc_issuer_url            = string
    eks_oidc_provider_arn          = string
    tags                           = map(string)
  })
}

variable "karpenter_provisioner_name" {
  description = "Name to use for the karpenter Provisioner object."
  type        = string
}

variable "eks_cluster_version" {
  description = "EKS cluster version of provisioned cluster."
  type        = string
}

variable "worker_node_security_group_id" {
  description = "Security group to apply as default for worker nodes."
  type        = string
}

variable "worker_node_iam_instance_profile" {
  description = "IAM instance profile the worker nodes should use."
  type        = string
}

variable "launch_template_pre_userdata" {
  description = "Run during cloud-init before running EKS bootstrap."
  type        = string
  default     = null
}

variable "launch_template_bootstrap_extra_args" {
  description = "Add to EKS bootstrap run during cloud-init."
  type        = string
  default     = null
}

variable "launch_template_post_userdata" {
  description = "Run during cloud-init after running EKS bootstrap."
  type        = string
  default     = null
}

variable "launch_template_kubelet_extra_args" {
  description = "Add to the kubelet-extra-args parameter when running EKS bootstrap."
  type        = string
  default     = null
}
