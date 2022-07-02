output "eks_cluster_id" {
  description = "Current AWS EKS Cluster ID"
  value       = local.addon_context.eks_cluster_id
}
