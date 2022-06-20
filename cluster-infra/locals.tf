locals {
  account_id       = data.aws_caller_identity.current.account_id
  partition_id     = data.aws_partition.current.id
  partition_suffix = data.aws_partition.current.dns_suffix
  cluster_name     = module.this.name_prefix
  lb_name          = local.cluster_name

  eks_map_roles = concat(
    [{
      rolearn  = data.aws_iam_role.administrator.arn
      username = "administrator"
      groups   = ["system:masters"]
    }],
    var.eks_map_roles
  )

  all_cidrs = [for cba in data.aws_vpc.shared.cidr_block_associations : cba.cidr_block]

  log_kms_name  = "${local.cluster_name}-ekslogs"
  log_kms_alias = "alias/eks_logs_key"

  create_logs_bucket = var.enable_access_logs && var.create_access_logs_bucket
  logs_bucket_name = var.create_access_logs_bucket && length(var.access_logs_bucket) == 0 ? (
    "${local.cluster_name}-logs"
    ) : (
    var.access_logs_bucket
  )

  dns_name = "${var.subdomain_part}.${data.aws_route53_zone.public.name}"
  acm_name = "*.${local.dns_name}"
  acm_alternatives = [
    local.dns_name,
    local.acm_name,
  ]
  domain_validation_options = var.create_acm_certificate ? (
    aws_acm_certificate.ingress[0].domain_validation_options
    ) : (
    []
  )
  zone_id             = data.aws_route53_zone.public.zone_id
  acm_certificate_arn = var.create_acm_certificate ? aws_acm_certificate.ingress[0].arn : var.acm_certificate_arn

}
