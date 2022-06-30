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

variable "secret_namespace" {
  description = "Kubernetes namespace to deploy bootstrap self-signer in."
  type        = string
  default     = "cert-manager"
}

variable "acme_challenge_method" {
  description = "If using the ACME Issuer, the challenge method which should be used."
  type        = string
  default     = "DNS01"

  validation {
    condition     = contains(["DNS01", "HTTP01"], var.acme_challenge_method)
    error_message = "Allowed values: `DNS01`, `HTTP01`."
  }
}

variable "cert_admin_email" {
  description = "Email address Let's Encrypt should contact the certificate administrator at."
  type        = string
  default     = ""
}

variable "acme_server" {
  description = "Let's Encrypt URL to contact for certificate signing."
  type        = string
  default     = "https://acme-staging-v02.api.letsencrypt.org/directory"
}

variable "route53_hosted_zone_name" {
  description = "Route53 public zone that DNS01 records should be written to."
  type        = string
  default     = ""
}

variable "ingress_class" {
  description = "If using the ACME Issuer and HTTP01 chanllenge method, the ingress class to use."
  type        = string
  default     = "conduit"
}
