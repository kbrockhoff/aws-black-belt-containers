locals {
  name_iam            = "${var.cluster_name}-cert-manager-irsa"
  name_certmgr        = "${var.system_name}-cert-manager"
  name_cainjector     = "${var.system_name}-cert-manager-cainjector"
  name_webhook        = "${var.system_name}-cert-manager-webhook"
  name_issuers        = "${var.system_name}-cert-manager-controller-issuers"
  name_clusterissuers = "${var.system_name}-cert-manager-controller-clusterissuers"
  name_certificates   = "${var.system_name}-cert-manager-controller-certificates"
  name_orders         = "${var.system_name}-cert-manager-controller-orders"
  name_challenges     = "${var.system_name}-cert-manager-controller-challenges"
  name_ingressshim    = "${var.system_name}-cert-manager-controller-ingress-shim"
  name_view           = "${var.system_name}-cert-manager-view"
  name_edit           = "${var.system_name}-cert-manager-edit"
  name_approve        = "${var.system_name}-cert-manager-controller-approve:cert-manager-io"
  name_csr            = "${var.system_name}-cert-manager-controller-certificatesigningrequests"
  name_sar            = "${var.system_name}-cert-manager-webhook:subjectaccessreviews"
  name_startupcheck   = "${var.system_name}-cert-manager-startupapicheck"
  labels_cainjector = {
    "app"                          = "cainjector"
    "app.kubernetes.io/component"  = "cainjector"
    "app.kubernetes.io/instance"   = var.system_name
    "app.kubernetes.io/managed-by" = "Terraform"
    "app.kubernetes.io/name"       = "cainjector"
    "app.kubernetes.io/version"    = var.cert_manager_version
  }
  labels_controller = {
    "app"                          = "cert-manager"
    "app.kubernetes.io/component"  = "controller"
    "app.kubernetes.io/instance"   = var.system_name
    "app.kubernetes.io/managed-by" = "Terraform"
    "app.kubernetes.io/name"       = "cert-manager"
    "app.kubernetes.io/version"    = var.cert_manager_version
  }
  labels_webhook = {
    "app"                          = "webhook"
    "app.kubernetes.io/component"  = "webhook"
    "app.kubernetes.io/instance"   = var.system_name
    "app.kubernetes.io/managed-by" = "Terraform"
    "app.kubernetes.io/name"       = "webhook"
    "app.kubernetes.io/version"    = var.cert_manager_version
  }
  labels_certmgr = {
    "app"                          = "cert-manager"
    "app.kubernetes.io/component"  = "cert-manager"
    "app.kubernetes.io/instance"   = var.system_name
    "app.kubernetes.io/managed-by" = "Terraform"
    "app.kubernetes.io/name"       = "cert-manager"
    "app.kubernetes.io/version"    = var.cert_manager_version
  }
  labels_startup = {
    "app"                          = "startupapicheck"
    "app.kubernetes.io/component"  = "startupapicheck"
    "app.kubernetes.io/instance"   = var.system_name
    "app.kubernetes.io/managed-by" = "Terraform"
    "app.kubernetes.io/name"       = "startupapicheck"
    "app.kubernetes.io/version"    = var.cert_manager_version
  }

  certmgr_prometheus = {
    "prometheus.io/path"   = "/metrics"
    "prometheus.io/port"   = "9402"
    "prometheus.io/scrape" = "true"
  }
  certmgr_metrics_annotations = var.register_prometheus_endpoints ? local.certmgr_prometheus : {}

  enabled_selfsign = var.enabled && var.issuer_type == "SelfSigned"
  enabled_ca       = var.enabled && var.issuer_type == "CA"
  bootstrap_ca     = var.ca_certificate == null || var.ca_key == null
  enabled_vault    = var.enabled && var.issuer_type == "Vault"
  enabled_venafi   = var.enabled && var.issuer_type == "Venafi"
  enabled_acme     = var.enabled && var.issuer_type == "ACME"
  enabled_kms      = var.enabled && var.issuer_type == "KMS" && var.kms_key != null
  enabled_acm      = var.enabled && var.issuer_type == "ACM"
  enabled_cflare   = var.enabled && var.issuer_type == "Cloudflare"
  enabled_dns01    = local.enabled_acme && var.acme_challenge_method == "DNS01"

  irsa_annotations = {
    "eks.amazonaws.com/role-arn" = local.enabled_dns01 ? aws_iam_role.certmgr[0].arn : ""
  }
  certmgr_sa_annotations = local.enabled_dns01 ? local.irsa_annotations : {}

}
