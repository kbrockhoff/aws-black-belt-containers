variable "helm_config" {
  description = "Prometheus Stack Helm Configuration"
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

variable "ingress_hostnames" {
  description = "List of hostnames to route to Prometheus stack."
  type        = list(string)
  default     = []
}

variable "route53_zone_id" {
  description = "ID of the Route53 zone to place records in."
  type        = string
  default     = ""
}

variable "alb_dns_name" {
  description = "DNS name of ALB in front of cluster."
  type        = string
  default     = ""
}

variable "alb_zone_id" {
  description = "Route 53 zone fo ALB DNS record."
  type        = string
  default     = ""
}
