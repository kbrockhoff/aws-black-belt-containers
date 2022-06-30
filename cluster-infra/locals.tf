locals {
  account_id       = data.aws_caller_identity.current.account_id
  partition_id     = data.aws_partition.current.id
  partition_suffix = data.aws_partition.current.dns_suffix
  cluster_name     = module.this.name_prefix
  noderole_name    = "${local.cluster_name}-managednodes"
  lb_name          = local.cluster_name
  waf_name         = "${local.cluster_name}-waf"
  loggroup_name    = "/aws/containerinsights/${local.cluster_name}/application"

  eks_map_roles = concat([
    {
      rolearn  = "arn:${local.partition_id}:iam::${local.account_id}:role/${var.sso_administrator_role_name}"
      username = "admin:{{SessionName}}"
      groups   = ["system:masters"]
    },
    {
      rolearn  = "arn:${local.partition_id}:iam::${local.account_id}:role/${var.sso_poweruser_role_name}"
      username = "user:{{SessionName}}"
      groups   = ["cluster-admin"]
    },
    {
      rolearn  = "arn:${local.partition_id}:iam::${local.account_id}:role/${var.sso_readonly_role_name}"
      username = "user:{{SessionName}}"
      groups   = ["system:public-info-viewer"]
    },
    ],
    var.eks_map_roles
  )
  eks_map_users    = []
  eks_map_accounts = []

  all_cidrs = [for cba in data.aws_vpc.shared.cidr_block_associations : cba.cidr_block]

  log_kms_name     = "${local.cluster_name}-ekslogs"
  log_kms_alias    = "alias/${local.log_kms_name}-key"
  ebs_kms_name     = "${local.cluster_name}-ebs"
  ebs_kms_alias    = "alias/${local.ebs_kms_name}-key"
  cluster_role_arn = "arn:${local.partition_id}:iam::${local.account_id}:role/${local.cluster_name}-cluster-role"
  node_role_arn    = "arn:${local.partition_id}:iam::${local.account_id}:role/${local.noderole_name}"

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

  tls_crt = var.tls_crt_filename == null ? null : base64encode(file("${path.module}/${var.tls_crt_filename}"))
  tls_key = var.tls_key_filename == null ? null : base64encode(file("${path.module}/${var.tls_key_filename}"))
}
