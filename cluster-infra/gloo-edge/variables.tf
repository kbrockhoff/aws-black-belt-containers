variable "helm_config" {
  description = "Gloo Edge Helm Configuration"
  type        = any
  default     = {}
}

variable "manage_via_gitops" {
  description = "Determines if the add-on should be managed via GitOps."
  type        = bool
  default     = false
}

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

variable "create_target_group" {
  description = "Set to false to not create a new load balancer target group."
  type        = bool
  default     = true
}

variable "vpc_id" {
  description = "VPC the gateway is running in."
  type        = string
  default     = ""
}

variable "alb_https_listener_arn" {
  description = "ARN of the ALB Listener to bind the created TargetGroup to."
  type        = string
  default     = ""
}

variable "routed_host_names" {
  description = "Host header values to route to created target group."
  type        = list(string)
  default     = []
}
