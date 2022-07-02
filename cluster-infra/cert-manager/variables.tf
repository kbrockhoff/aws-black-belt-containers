variable "enabled" {
  description = "Set to false to prevent the module from creating any resources."
  type        = bool
  default     = true
}

variable "eks_cluster_id" {
  description = "EKS Cluster Id"
  type        = string
}

variable "helm_config" {
  description = "cert-manager Helm chart configuration"
  type        = any
  default     = {}
}

variable "irsa_policies" {
  description = "Additional IAM policies used for the add-on service account."
  type        = list(string)
  default     = []
}

variable "domain_names" {
  description = "Domain names of the Route53 hosted zone to use with cert-manager."
  type        = list(string)
  default     = []
}

variable "install_letsencrypt_issuers" {
  description = "Install Let's Encrypt Cluster Issuers."
  type        = bool
  default     = true
}

variable "letsencrypt_email" {
  description = "Email address for expiration emails from Let's Encrypt."
  type        = string
  default     = ""
}

variable "tags" {
  description = "Additional tags (e.g. `map('BusinessUnit`,`XYZ`)"
  type        = map(string)
  default     = {}
}
