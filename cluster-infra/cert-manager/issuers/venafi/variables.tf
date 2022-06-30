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
  description = "Kubernetes namespace to place issuer and/or secret in."
  type        = string
}

variable "system_name" {
  description = "System name to group all Kubernetes deployments under."
  type        = string
  default     = "cm"
}

variable "venafi_api_key" {
  description = "The Venafi-as-a-Service API key."
  type        = string
  default     = ""
}

variable "venafi_zone" {
  description = "The Venafi-as-a-Service Zone (<Application Name>\\<Issuing Template Alias>)."
  type        = string
  default     = ""
}

variable "tags" {
  description = "Resource tags defined in the parent module."
  type        = map(string)
  default     = {}
}
