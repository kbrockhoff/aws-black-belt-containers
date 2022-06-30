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

variable "namespace" {
  description = "Kubernetes namespace to create and deploy Cert Manager into."
  type        = string
  default     = "cert-manager"
}

variable "system_name" {
  description = "System name to group all Kubernetes deployments under."
  type        = string
  default     = "cm"
}

variable "cert_manager_version" {
  description = "Version of the Cert Manager being used."
  type        = string
  default     = "v1.8.2"
}

variable "image_cainjector" {
  description = "Image ID of Cert Manager CAInjector image to use in deployment."
  type        = string
  default     = "quay.io/jetstack/cert-manager-cainjector:v1.8.2"
}

variable "image_controller" {
  description = "Image ID of Cert Manager Controller image to use in deployment."
  type        = string
  default     = "quay.io/jetstack/cert-manager-controller:v1.8.2"
}

variable "image_webhook" {
  description = "Image ID of Cert Manager Webhook image to use in deployment."
  type        = string
  default     = "quay.io/jetstack/cert-manager-webhook:v1.8.2"
}

variable "image_startup" {
  description = "Image ID of Cert Manager Startup Job image to use in deployment."
  type        = string
  default     = "quay.io/jetstack/cert-manager-ctl:v1.8.2"
}

variable "replicas_cainjector" {
  description = "Number of Cert Manager CAInjector pods."
  type        = number
  default     = 1
}

variable "resources_cainjector" {
  description = "Resource settings for Cert Manager CAInjector pods."
  type        = object({ requests = map(string), limits = map(string) })
  default     = { requests = null, limits = null }
}

variable "replicas_controller" {
  description = "Number of Cert Manager Controller pods."
  type        = number
  default     = 1
}

variable "resources_controller" {
  description = "Resource settings for Cert Manager Controller pods."
  type        = object({ requests = map(string), limits = map(string) })
  default     = { requests = null, limits = null }
}

variable "replicas_webhook" {
  description = "Number of Cert Manager Webhook pods."
  type        = number
  default     = 1
}

variable "resources_webhook" {
  description = "Resource settings for Cert Manager Webhook pods."
  type        = object({ requests = map(string), limits = map(string) })
  default     = { requests = null, limits = null }
}

variable "resources_startupapicheck" {
  description = "Resource settings for Cert Manager startup check job pods."
  type        = object({ requests = map(string), limits = map(string) })
  default     = { requests = null, limits = null }
}

variable "register_prometheus_endpoints" {
  description = "Set to false to not register metrics endpoints with Prometheus."
  type        = bool
  default     = true
}

variable "issuer_type" {
  description = "Issuer which will be used to issue certificates from enumerated list."
  type        = string
  default     = "SelfSigned"

  validation {
    condition     = contains(["SelfSigned", "CA", "Vault", "Venafi", "ACME", "KMS", "ACM", "Cloudflare"], var.issuer_type)
    error_message = "Allowed values: `SelfSigned`, `CA`, `Vault`, `Venafi`, `ACME`, `KMS`, `ACM`, `Cloudflare`."
  }
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

variable "kms_key" {
  description = "If using the KMS issuer type, the KMS key ARN for the asymetric key used to sign certificates."
  type        = string
  default     = null
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
  description = "If using the ACME Issuer, email address Let's Encrypt should contact the certificate administrator at."
  type        = string
  default     = ""
}

variable "acme_server" {
  description = "If using the ACME Issuer, Let's Encrypt URL to contact for certificate signing."
  type        = string
  default     = "https://acme-staging-v02.api.letsencrypt.org/directory"
}

variable "route53_hosted_zone_name" {
  description = "If using the ACME Issuer, Route53 public zone DNS01 records should be written to."
  type        = string
  default     = ""
}

variable "awspca_privateca_arn" {
  description = "The ARN for the AWS Certificate Manager Private CA."
  type        = string
  default     = ""
}

variable "venafi_api_key" {
  description = "If using the Venafi Issuer, Venafi-as-a-Service API key."
  type        = string
  default     = ""
}

variable "venafi_zone" {
  description = "If using the Venafi Issuer, Venafi-as-a-Service Zone (<Application Name>\\<Issuing Template Alias>)."
  type        = string
  default     = ""
}

variable "tags" {
  description = "Resource tags defined in the parent module."
  type        = map(string)
  default     = {}
}

