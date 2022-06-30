locals {
  ca_name          = "${var.cluster_name}-ca"
  ca_secret        = "${var.cluster_name}-ca-secret"
  bootstrap_issuer = "selfsigned-bootstrap-issuer"
  issuer           = var.namespace == null ? "" : "${var.namespace}-ca-issuer"
  cluster_issuer   = "${var.cluster_name}-ca-issuer"
}
