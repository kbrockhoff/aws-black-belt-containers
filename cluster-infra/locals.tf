locals {
  name             = module.this.name_prefix
  account_id       = data.aws_caller_identity.current.account_id
  partition_id     = data.aws_partition.current.id
  partition_suffix = data.aws_partition.current.dns_suffix

  eks_map_roles = concat(
    [{
      rolearn  = "arn:${local.partition_id}:iam::${local.account_id}:role/administrator"
      username = "administrator"
      groups   = ["system:masters"]
    }],
    var.eks_map_roles
  )

  all_cidrs = [for cba in data.aws_vpc.shared.cidr_block_associations : cba.cidr_block]

  log_kms_name  = "${local.name}-ekslogs"
  log_kms_alias = "alias/eks_logs_key"

}
