resource "kubernetes_service_account" "awspca_issuer" {
  count = var.enabled ? 1 : 0

  metadata {
    name      = local.name_caissuer
    namespace = var.namespace
    labels    = local.labels_caissuer
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.awspca_issuer[0].arn
    }
  }
  automount_service_account_token = true
}

resource "kubernetes_cluster_role" "awspca_issuer" {
  count = var.enabled ? 1 : 0

  metadata {
    name   = local.name_caissuer
    labels = local.labels_caissuer
  }

  rule {
    api_groups = [
      "",
      "coordination.k8s.io",
    ]
    resources = [
      "configmaps",
      "leases",
    ]
    verbs = [
      "get",
      "list",
      "watch",
      "create",
      "update",
      "patch",
      "delete",
    ]
  }
  rule {
    api_groups = [
      "",
    ]
    resources = [
      "events",
    ]
    verbs = [
      "create",
      "patch",
    ]
  }
  rule {
    api_groups = [
      "",
    ]
    resources = [
      "secrets",
    ]
    verbs = [
      "get",
      "list",
      "watch",
    ]
  }
  rule {
    api_groups = [
      "awspca.cert-manager.io",
    ]
    resources = [
      "awspcaclusterissuers",
    ]
    verbs = [
      "create",
      "delete",
      "get",
      "list",
      "patch",
      "update",
      "watch",
    ]
  }
  rule {
    api_groups = [
      "awspca.cert-manager.io",
    ]
    resources = [
      "awspcaclusterissuers/finalizers",
    ]
    verbs = [
      "update",
    ]
  }
  rule {
    api_groups = [
      "awspca.cert-manager.io",
    ]
    resources = [
      "awspcaclusterissuers/status",
    ]
    verbs = [
      "get",
      "patch",
      "update",
    ]
  }
  rule {
    api_groups = [
      "awspca.cert-manager.io",
    ]
    resources = [
      "awspcaissuers",
    ]
    verbs = [
      "create",
      "delete",
      "get",
      "list",
      "patch",
      "update",
      "watch",
    ]
  }
  rule {
    api_groups = [
      "awspca.cert-manager.io",
    ]
    resources = [
      "awspcaissuers/finalizers",
    ]
    verbs = [
      "update",
    ]
  }
  rule {
    api_groups = [
      "awspca.cert-manager.io",
    ]
    resources = [
      "awspcaissuers/status",
    ]
    verbs = [
      "get",
      "patch",
      "update",
    ]
  }
  rule {
    api_groups = [
      "cert-manager.io",
    ]
    resources = [
      "certificaterequests",
    ]
    verbs = [
      "get",
      "list",
      "update",
      "watch",
    ]
  }
  rule {
    api_groups = [
      "cert-manager.io",
    ]
    resources = [
      "certificaterequests/status",
    ]
    verbs = [
      "get",
      "patch",
      "update",
    ]
  }
}

resource "kubernetes_cluster_role" "cert_manager_controller_approve" {
  count = var.enabled ? 1 : 0

  metadata {
    name   = "${local.name_caissuer}-controller-approve"
    labels = local.labels_caissuer
  }

  rule {
    api_groups = [
      "cert-manager.io",
    ]
    resource_names = [
      "awspcaclusterissuers.awspca.cert-manager.io/*",
      "awspcaissuers.awspca.cert-manager.io/*",
    ]
    resources = [
      "signers",
    ]
    verbs = [
      "approve",
    ]
  }
}

resource "kubernetes_cluster_role_binding" "awspca_issuer" {
  count = var.enabled ? 1 : 0

  metadata {
    name   = local.name_caissuer
    labels = local.labels_caissuer
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.awspca_issuer[0].metadata[0].name
  }
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.awspca_issuer[0].metadata[0].name
    namespace = kubernetes_service_account.awspca_issuer[0].metadata[0].namespace
  }
}

resource "kubernetes_cluster_role_binding" "cert_manager_controller_approve" {
  count = var.enabled ? 1 : 0

  metadata {
    name   = "${local.name_caissuer}-controller-approve"
    labels = local.labels_caissuer
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.cert_manager_controller_approve[0].metadata[0].name
  }
  subject {
    kind      = "ServiceAccount"
    name      = var.cert_manager_service_account_name
    namespace = var.cert_manager_service_account_namespace
  }
}

resource "kubernetes_service" "awspca_issuer" {
  count = var.enabled ? 1 : 0

  metadata {
    name      = local.name_caissuer
    namespace = var.namespace
    labels    = local.labels_caissuer
  }
  spec {
    port {
      name        = "http"
      port        = 8080
      protocol    = "TCP"
      target_port = "http"
    }
    selector = {
      "app.kubernetes.io/instance" = var.system_name
      "app.kubernetes.io/name"     = "aws-privateca-issuer"
    }
    type = "ClusterIP"
  }
}

resource "kubernetes_deployment" "awspca_issuer" {
  count = var.enabled ? 1 : 0

  metadata {
    name      = local.name_caissuer
    namespace = var.namespace
    labels    = local.labels_caissuer
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        "app.kubernetes.io/instance" = var.system_name
        "app.kubernetes.io/name"     = "aws-privateca-issuer"
      }
    }
    template {
      metadata {
        labels = {
          "app.kubernetes.io/instance" = var.system_name
          "app.kubernetes.io/name"     = "aws-privateca-issuer"
        }
      }
      spec {
        container {
          args = [
            "--leader-elect",
          ]
          command = [
            "/manager",
          ]
          image             = "public.ecr.aws/k1n1h4h4/cert-manager-aws-privateca-issuer:latest"
          image_pull_policy = "IfNotPresent"
          liveness_probe {
            http_get {
              path = "/healthz"
              port = 8081
            }
            initial_delay_seconds = 15
            period_seconds        = 20
          }
          name = "aws-privateca-issuer"
          port {
            container_port = 8080
            name           = "http"
          }
          readiness_probe {
            http_get {
              path = "/healthz"
              port = 8081
            }
            initial_delay_seconds = 5
            period_seconds        = 10
          }
          resources {
            limits   = null
            requests = null
          }
          security_context {
            allow_privilege_escalation = false
          }
        }
        security_context {
          run_as_user = 65532
        }
        service_account_name             = kubernetes_service_account.awspca_issuer[0].metadata[0].name
        termination_grace_period_seconds = 10
      }
    }
  }
}
