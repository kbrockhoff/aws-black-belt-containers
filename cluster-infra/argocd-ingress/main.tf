resource "kubernetes_ingress_v1" "server_http" {
  metadata {
    name        = "${local.server_name}-http"
    namespace   = var.namespace
    labels      = local.server_labels
    annotations = local.http_ingress_annotations
  }
  spec {
    ingress_class_name = var.ingress_class
    dynamic "rule" {
      for_each = var.ingress_hostnames
      content {
        host = rule.value
        http {
          path {
            path = "/"
            backend {
              service {
                name = local.server_name
                port {
                  name = "https"
                }
              }
            }
          }
        }
      }
    }
    tls {
      hosts       = var.ingress_hostnames
      secret_name = "${var.helm_prefix}-server-tls"
    }
  }
}
