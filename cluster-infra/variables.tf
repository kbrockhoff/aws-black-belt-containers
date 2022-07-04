variable "region" {
  description = "Default infrastructure region"
  type        = string
  default     = "us-west-2"
}

variable "sso_administrator_role_name" {
  description = "Name of IAM role tied to AWS SSO for Administrator access."
  type        = string
}

variable "sso_poweruser_role_name" {
  description = "Name of IAM role tied to AWS SSO for PowerUser access."
  type        = string
}

variable "sso_readonly_role_name" {
  description = "Name of IAM role tied to AWS SSO for ReadOnly access."
  type        = string
}

variable "github_role_name" {
  description = "Name of IAM role used by GitHub Actions."
  type        = string
}

variable "eks_version" {
  description = "Version of the EKS K8S cluster"
  type        = string
  default     = "1.22"
}

variable "cluster_enabled_log_types" {
  description = "A list of the desired control plane logging to enable."
  type        = list(string)
  default     = ["api", "controllerManager", "scheduler", "audit", "authenticator"]
}

variable "eks_map_roles" {
  description = "Additional IAM roles to add to the aws-auth configmap."
  type = list(object({
    rolearn  = string
    username = string
    groups   = list(string)
  }))
  default = []
}

variable "eks_write_kubeconfig" {
  description = "Flag for eks module to write kubeconfig"
  default     = false
}

variable "enable_access_logs" {
  description = "Set to false to disable access logging."
  type        = bool
  default     = true
}

variable "create_access_logs_bucket" {
  description = "Set to false to use supplied access logs bucket."
  type        = bool
  default     = true
}

variable "access_logs_bucket" {
  description = "The S3 bucket name to store the access logs in if not creating."
  type        = string
  default     = ""
}

variable "elb_account_id" {
  description = "The Elastic Load Balancing account ID for the region."
  type        = string
  default     = "797873946194"
}

variable "subdomain_part" {
  description = "Subdomain within the public domain name for the account to assign to the created load balancer."
  type        = string
  default     = ""
}

variable "create_acm_certificate" {
  description = "Set to false to not request and validate an ACM certificate."
  type        = bool
  default     = true
}

variable "acm_certificate_arn" {
  description = "If not creating ACM-managed certificate, the ARN of the default certificate to use."
  type        = string
  default     = ""
}

variable "additional_acm_certs" {
  description = "ARN's of addtional ACM-managed certificates which load balancer should support via SNI."
  type        = list(string)
  default     = []
}

variable "log_retention_days" {
  description = "Number of days to retain CloudWatchLogs."
  type        = number
  default     = 14
}

variable "argocd_admin_password_secret_name" {
  description = "Name for a secret stored in AWS Secrets Manager that contains the admin password"
  type        = string
  default     = ""
}

variable "tls_crt_filename" {
  description = "Path to the file containing the certificate chain for the CA signing certificate to use."
  type        = string
  default     = null
}

variable "tls_key_filename" {
  description = "Path to the file containing the private key for the CA signing certificate to use."
  type        = string
  default     = null
}

variable "cert_admin_email" {
  description = "If using the ACME Issuer, email address Let's Encrypt should contact the certificate administrator at."
  type        = string
  default     = "Kevin.Brockhoff@daugherty.com"
}
