locals {
  issuer         = var.namespace == null ? "" : "${var.namespace}-ca-issuer"
  cluster_issuer = "${var.cluster_name}-ca-issuer"
  name_caissuer  = "${var.system_name}-aws-privateca-issuer"
  labels_caissuer = {
    "app.kubernetes.io/instance"   = var.system_name
    "app.kubernetes.io/managed-by" = "Terraform"
    "app.kubernetes.io/name"       = "aws-privateca-issuer"
    "app.kubernetes.io/version"    = "v1.1.0"
  }
}
