output "logs_kms_key_arn" {
  description = "ARN of customer-managed key used for control plane logs encryption."
  value       = module.logs_kms_key.key_arn
}

output "logs_kms_key_alias" {
  description = "Alias of customer-managed key used for control plane logs encryption."
  value       = module.logs_kms_key.alias_name
}

output "eks_cluster_id" {
  description = "Amazon EKS Cluster Name."
  value       = module.eks_blueprints.eks_cluster_id
}

output "eks_cluster_certificate_authority_data" {
  description = "Base64 encoded certificate data required to communicate with the cluster."
  value       = module.eks_blueprints.eks_cluster_certificate_authority_data
}

output "eks_cluster_endpoint" {
  description = "Endpoint for your Kubernetes API server."
  value       = module.eks_blueprints.eks_cluster_endpoint
}

output "eks_oidc_issuer_url" {
  description = "The URL on the EKS cluster OIDC Issuer."
  value       = module.eks_blueprints.eks_oidc_issuer_url
}

output "eks_oidc_provider_arn" {
  description = "The ARN of the OIDC Provider."
  value       = module.eks_blueprints.eks_oidc_provider_arn
}
