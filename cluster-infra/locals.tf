locals {
  account_id       = data.aws_caller_identity.current.account_id
  partition_id     = data.aws_partition.current.id
  partition_suffix = data.aws_partition.current.dns_suffix
  cluster_name     = module.this.name_prefix
  noderole_name    = "${local.cluster_name}-managednodes"
  lb_name          = local.cluster_name
  waf_name         = "${local.cluster_name}-waf"
  appslog_name     = "/dl/eks/${local.cluster_name}/application"
  datalog_name     = "/dl/eks/${local.cluster_name}/dataplane"
  hostlog_name     = "/dl/eks/${local.cluster_name}/host"
  argocd_name      = "${local.cluster_name}-argocd"

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

  cluster_svc_cidr = "172.20.0.0/16"
  all_cidrs        = [for cba in data.aws_vpc.shared.cidr_block_associations : cba.cidr_block]
  lb_av_zones      = [for sn in data.aws_subnet.lb : sn.availability_zone]
  node_av_zones    = [for sn in data.aws_subnet.node : sn.availability_zone]
  alwayson_subnets = [for sn in data.aws_subnet.node : sn.id if contains(local.lb_av_zones, sn.availability_zone)]

  log_kms_name     = "${local.cluster_name}-ekslogs"
  ebs_kms_name     = "${local.cluster_name}-ebs"
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

  generate_ca_cert = var.tls_key_filename == null
  tls_crt = local.generate_ca_cert ? (
    base64encode(tls_self_signed_cert.certmgr_ca[0].cert_pem)
    ) : (
    base64encode(file("${path.module}/${var.tls_crt_filename}"))
  )
  tls_key = local.generate_ca_cert ? (
    base64encode(tls_self_signed_cert.certmgr_ca[0].private_key_pem)
    ) : (
    base64encode(file("${path.module}/${var.tls_key_filename}"))
  )

  alertmanager_hosts = [
    "alerts.${local.dns_name}",
  ]
  grafana_hosts = [
    "metrics.${local.dns_name}",
  ]

  create_backups_bucket = var.create_backups_bucket
  backups_bucket_name = length(var.backups_bucket) == 0 ? (
    "${local.cluster_name}-backups"
    ) : (
    var.backups_bucket
  )
  backup_iam_role = "arn:aws:iam::${local.account_id}:role/${local.cluster_name}-velero-sa-irsa"
}

resource "tls_private_key" "certmgr_ca" {
  count = local.generate_ca_cert ? 1 : 0

  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "tls_self_signed_cert" "certmgr_ca" {
  count = local.generate_ca_cert ? 1 : 0

  private_key_pem = tls_private_key.certmgr_ca[0].private_key_pem
  allowed_uses = [
    "cert_signing",
    "crl_signing",
    "digital_signature",
  ]
  validity_period_hours = 87600
  is_ca_certificate     = true
  subject {
    common_name         = "${local.cluster_name} CA"
    country             = "US"
    locality            = "St Louis"
    organization        = "Daugherty Systems, Inc."
    organizational_unit = "Daugherty Labs"
    postal_code         = "63141"
    province            = "MO"
  }
}
