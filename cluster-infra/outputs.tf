output "logs_kms_key_arn" {
  description = "ARN of customer-managed key used for control plane logs encryption."
  value       = aws_kms_key.logs.arn
}

output "logs_kms_key_alias" {
  description = "Alias of customer-managed key used for control plane logs encryption."
  value       = aws_kms_key.ebs.arn
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

output "applications_log_group_name" {
  description = "Name of log group holding workloads logs."
  value       = aws + aws_cloudwatch_log_group.applications.name
}

output "dataplane_log_group_name" {
  description = "Name of log group holding cluster data plane logs."
  value       = aws + aws_cloudwatch_log_group.dataplane.name
}

output "host_log_group_name" {
  description = "Name of log group holding cluster host VM logs."
  value       = aws + aws_cloudwatch_log_group.host.name
}
