variable "enabled" {
  description = "Set to false to prevent the module from creating any resources."
  type        = bool
  default     = true
}

variable "install_crds" {
  description = "Set to false to not install Cert Manager CRDs."
  type        = bool
  default     = true
}

variable "cluster_name" {
  description = "Name of the EKS cluster. Also used as a prefix in names of related resources."
  type        = string
}

variable "provision_cluster_issuer" {
  description = "Set to false to prevent creation of a ClusterIssuer."
  type        = bool
  default     = true
}

variable "namespace" {
  description = "Kubernetes namespace to place issuer in."
  type        = string
  default     = null
}

variable "system_name" {
  description = "System name to group all Kubernetes deployments under."
  type        = string
  default     = "cm"
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

variable "awspca_privateca_arn" {
  description = "The ARN for the AWS Certificate Manager Private CA."
  type        = string
}

variable "cert_manager_service_account_name" {
  description = "Name of the Kubernetes service account the parent Cert Manager is running under."
  type        = string
}

variable "cert_manager_service_account_namespace" {
  description = "Namespace of the Kubernetes service account the parent Cert Manager is running under."
  type        = string
}

variable "tags" {
  description = "Resource tags defined in the parent module."
  type        = map(string)
  default     = {}
}
