locals {
  provision_issuer = !var.provision_cluster_issuer
  name_secret      = "${var.system_name}-venafi-apikey"
  issuer           = "${var.namespace}-ca-issuer"
  cluster_issuer   = "${var.cluster_name}-ca-issuer"
}
