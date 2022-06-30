variable "enabled" {
  description = "Set to false to prevent the module from creating any resources."
  type        = bool
  default     = true
}

variable "cluster_name" {
  description = "Name of the EKS cluster. Also used as a prefix in names of related resources."
  type        = string
}

variable "bootstrap_ca" {
  description = "Set to false to use supplied signing certificate instead of creating a self-signed one."
  type        = bool
  default     = true
}

variable "provision_cluster_issuer" {
  description = "Set to false to prevent creation of a ClusterIssuer."
  type        = bool
  default     = true
}

variable "ca_certificate" {
  description = "If using the CA issuer type, public key of the Certificate Authority signing certificate."
  type        = string
  default     = null
}

variable "ca_key" {
  description = "If using the CA issuer type, private key of the Certificate Authority signing certificate."
  type        = string
  default     = null
}

variable "namespace" {
  description = "Kubernetes namespace to place issuer in."
  type        = string
  default     = null
}

variable "secret_namespace" {
  description = "Kubernetes namespace to deploy bootstrap self-signer in."
  type        = string
  default     = "cert-manager"
}
