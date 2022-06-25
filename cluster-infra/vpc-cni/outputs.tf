output "pod_security_group_id" {
  description = "Security group ID attached to the EKS pods."
  value       = local.pod_security_group_id
}
