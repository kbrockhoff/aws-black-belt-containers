variable "enabled" {
  description = "Set to false to prevent the module from creating any resources."
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
