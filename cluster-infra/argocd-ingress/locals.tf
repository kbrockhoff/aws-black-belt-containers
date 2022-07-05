locals {
  server_name = "${var.helm_prefix}-${var.server_name}"
  server_labels = {
    "app.kubernetes.io/component" = "server"
    "app.kubernetes.io/instance"  = var.helm_prefix
    "app.kubernetes.io/name"      = var.server_name
    "app.kubernetes.io/part-of"   = "argocd"
  }

  http_ingress_annotations = {
    "ingress.kubernetes.io/force-ssl-redirect" = "true"
    "cert-manager.io/cluster-issuer"           = var.cert_manager_cluster_issuer
  }
  grpc_ingress_annotations = {
    "cert-manager.io/cluster-issuer" = var.cert_manager_cluster_issuer
  }
}