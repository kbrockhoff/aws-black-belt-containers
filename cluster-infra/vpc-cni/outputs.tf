output "pod_security_group_id" {
  description = "Security group ID attached to the EKS pods."
  value       = local.pod_security_group_id
}

output "vpc_cni_iam_role_name" {
  description = "IAM role name used by the Amazon CNI plugin addon."
  value       = join("", aws_iam_role.vpc_cni.*.name)
}

output "vpc_cni_iam_role_arn" {
  description = "IAM role ARN used by the Amazon CNI plugin addon."
  value       = join("", aws_iam_role.vpc_cni.*.arn)
}
