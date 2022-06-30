locals {
  ca_name        = "${var.cluster_name}-ca"
  ca_secret      = "${var.cluster_name}-ca-secret"
  issuer         = var.namespace == null ? "" : "${var.namespace}-ca-issuer"
  cluster_issuer = "${var.cluster_name}-ca-issuer"

  enabled_via_dns01  = var.enabled && var.acme_challenge_method == "DNS01"
  enabled_via_http01 = var.enabled && var.acme_challenge_method == "HTTP01"
}
