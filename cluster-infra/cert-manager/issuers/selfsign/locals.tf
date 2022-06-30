locals {
  issuer         = var.namespace == null ? "" : "${var.namespace}-ca-issuer"
  cluster_issuer = "${var.cluster_name}-ca-issuer"
}
