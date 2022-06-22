variable "enabled" {
  description = "Set to false to prevent the module from creating any resources."
  type        = bool
  default     = true
}

variable "cluster_name" {
  description = "Name of the EKS cluster. Also used as a prefix in names of related resources."
  type        = string
}

variable "vpc_id" {
  description = "VPC where the cluster and workers will be deployed."
  type        = string
}

variable "vpccni_version" {
  description = "vpc-cni addon version to use."
  type        = string
  default     = "v1.10.1-eksbuild.1"
}

variable "pod_subnets" {
  description = "A list of subnets to place the EKS pods within if using the vpc-cni addon."
  type        = list(string)
  default     = []
}

variable "enable_custom_network" {
  description = "Whether to enable the vpc-cni custom network env variable which should be true if pods use different subnet than nodes."
  type        = bool
  default     = true
}

variable "pod_create_security_group" {
  description = "When using vpc-cni whether to create a separate security group for the pods or attach the pod to `pod_security_group_id`."
  type        = bool
  default     = true
}

variable "pod_security_group_id" {
  description = "If provided, all pods will be attached to this security group. If not given, a security group will be created with necessary ingress/egress to work with the EKS cluster."
  type        = string
  default     = ""
}

variable "pods_egress_cidrs" {
  description = "List of CIDR blocks that are permitted for workers egress traffic."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "cluster_security_group_id" {
  description = "If provided, the EKS cluster will be attached to this security group. If not given, a security group will be created with necessary ingress/egress to work with the workers"
  type        = string
  default     = ""
}

variable "cluster_oidc_issuer_url" {
  description = "The URL on the EKS cluster OIDC Issuer"
  type        = string
  default     = ""
}

variable "oidc_provider_arn" {
  description = "The ARN of the OIDC Provider."
  type        = string
  default     = ""
}

variable "tags" {
  description = "Resource tags defined in the parent module."
  type        = map(string)
  default     = {}
}