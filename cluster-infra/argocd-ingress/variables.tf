variable "namespace" {
  description = "Kubernetes namespace of ArgoCD."
  type        = string
  default     = "argocd"
}

variable "helm_prefix" {
  description = "Indentifier used by Helm for the install."
  type        = string
  default     = "argo-cd"
}

variable "server_name" {
  description = "Name of ArgoCD server deployment."
  type        = string
  default     = "argocd-server"
}

variable "ingress_class" {
  description = "Name of the ingress class to use."
  type        = string
  default     = "nginx"
}

variable "cert_manager_cluster_issuer" {
  description = "Name of the Cert Manager cluster issuer to use in generating cert for the ingress."
  type        = string
  default     = "cert-manager-ca"
}

variable "ingress_hostnames" {
  description = "List of hostnames to route to ArgoCD"
  type        = list(string)
  default     = []
}
