resource "kubernetes_namespace" "cert_manager" {
  count = var.enabled ? 1 : 0

  metadata {
    name = var.namespace
  }
}

resource "kubernetes_service_account" "cainjector" {
  count = var.enabled ? 1 : 0

  metadata {
    name      = local.name_cainjector
    namespace = kubernetes_namespace.cert_manager[0].metadata[0].name
    labels    = local.labels_cainjector
  }
  automount_service_account_token = true
}

resource "kubernetes_service_account" "cert_manager" {
  count = var.enabled ? 1 : 0

  metadata {
    name        = local.name_certmgr
    namespace   = kubernetes_namespace.cert_manager[0].metadata[0].name
    labels      = local.labels_controller
    annotations = local.certmgr_sa_annotations
  }
  automount_service_account_token = true

  depends_on = [aws_iam_role.acme_issuer]
}

resource "kubernetes_service_account" "webhook" {
  count = var.enabled ? 1 : 0

  metadata {
    name      = local.name_webhook
    namespace = kubernetes_namespace.cert_manager[0].metadata[0].name
    labels    = local.labels_webhook
  }
  automount_service_account_token = true
}

resource "kubernetes_cluster_role" "cainjector" {
  count = var.enabled ? 1 : 0

  metadata {
    name   = local.name_cainjector
    labels = local.labels_cainjector
  }

  rule {
    api_groups = [
      "cert-manager.io",
    ]
    resources = [
      "certificates",
    ]
    verbs = [
      "get",
      "list",
      "watch",
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
      "",
    ]
    resources = [
      "events",
    ]
    verbs = [
      "get",
      "create",
      "update",
      "patch",
    ]
  }
  rule {
    api_groups = [
      "admissionregistration.k8s.io",
    ]
    resources = [
      "validatingwebhookconfigurations",
      "mutatingwebhookconfigurations",
    ]
    verbs = [
      "get",
      "list",
      "watch",
      "update",
    ]
  }
  rule {
    api_groups = [
      "apiregistration.k8s.io",
    ]
    resources = [
      "apiservices",
    ]
    verbs = [
      "get",
      "list",
      "watch",
      "update",
    ]
  }
  rule {
    api_groups = [
      "apiextensions.k8s.io",
    ]
    resources = [
      "customresourcedefinitions",
    ]
    verbs = [
      "get",
      "list",
      "watch",
      "update",
    ]
  }
  rule {
    api_groups = [
      "auditregistration.k8s.io",
    ]
    resources = [
      "auditsinks",
    ]
    verbs = [
      "get",
      "list",
      "watch",
      "update",
    ]
  }
}

resource "kubernetes_cluster_role" "issuers" {
  count = var.enabled ? 1 : 0

  metadata {
    name   = local.name_issuers
    labels = local.labels_controller
  }

  rule {
    api_groups = [
      "cert-manager.io",
    ]
    resources = [
      "issuers",
      "issuers/status",
    ]
    verbs = [
      "update",
    ]
  }
  rule {
    api_groups = [
      "cert-manager.io",
    ]
    resources = [
      "issuers",
    ]
    verbs = [
      "get",
      "list",
      "watch",
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
      "create",
      "update",
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
}

resource "kubernetes_cluster_role" "clusterissuers" {
  count = var.enabled ? 1 : 0

  metadata {
    name   = local.name_clusterissuers
    labels = local.labels_controller
  }

  rule {
    api_groups = [
      "cert-manager.io",
    ]
    resources = [
      "clusterissuers",
      "clusterissuers/status",
    ]
    verbs = [
      "update",
    ]
  }
  rule {
    api_groups = [
      "cert-manager.io",
    ]
    resources = [
      "clusterissuers",
    ]
    verbs = [
      "get",
      "list",
      "watch",
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
      "create",
      "update",
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
}


resource "kubernetes_cluster_role" "controller_certificates" {
  count = var.enabled ? 1 : 0

  metadata {
    name   = local.name_certificates
    labels = local.labels_controller
  }

  rule {
    api_groups = [
      "cert-manager.io",
    ]
    resources = [
      "certificates",
      "certificates/status",
      "certificaterequests",
      "certificaterequests/status",
    ]
    verbs = [
      "update",
    ]
  }
  rule {
    api_groups = [
      "cert-manager.io",
    ]
    resources = [
      "certificates",
      "certificaterequests",
      "clusterissuers",
      "issuers",
    ]
    verbs = [
      "get",
      "list",
      "watch",
    ]
  }

  rule {
    api_groups = [
      "cert-manager.io",
    ]
    resources = [
      "certificates/finalizers",
      "certificaterequests/finalizers",
    ]
    verbs = [
      "update",
    ]
  }
  rule {
    api_groups = [
      "acme.cert-manager.io",
    ]
    resources = [
      "orders",
    ]
    verbs = [
      "create",
      "delete",
      "get",
      "list",
      "watch",
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
      "create",
      "update",
      "delete",
      "patch",
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
}

resource "kubernetes_cluster_role" "controller_orders" {
  count = var.enabled ? 1 : 0

  metadata {
    name   = local.name_orders
    labels = local.labels_controller
  }

  rule {
    api_groups = [
      "acme.cert-manager.io",
    ]
    resources = [
      "orders",
      "orders/status",
    ]
    verbs = [
      "update",
    ]
  }
  rule {
    api_groups = [
      "acme.cert-manager.io",
    ]
    resources = [
      "orders",
      "challenges",
    ]
    verbs = [
      "get",
      "list",
      "watch",
    ]
  }
  rule {
    api_groups = [
      "cert-manager.io",
    ]
    resources = [
      "clusterissuers",
      "issuers",
    ]
    verbs = [
      "get",
      "list",
      "watch",
    ]
  }
  rule {
    api_groups = [
      "acme.cert-manager.io",
    ]
    resources = [
      "challenges",
    ]
    verbs = [
      "create",
      "delete",
    ]
  }
  rule {
    api_groups = [
      "acme.cert-manager.io",
    ]
    resources = [
      "orders/finalizers",
    ]
    verbs = [
      "update",
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
}

resource "kubernetes_cluster_role" "controller_challenges" {
  count = var.enabled ? 1 : 0

  metadata {
    name   = local.name_challenges
    labels = local.labels_controller
  }

  rule {
    api_groups = [
      "acme.cert-manager.io",
    ]
    resources = [
      "challenges",
      "challenges/status",
    ]
    verbs = [
      "update",
    ]
  }
  rule {
    api_groups = [
      "acme.cert-manager.io",
    ]
    resources = [
      "challenges",
    ]
    verbs = [
      "get",
      "list",
      "watch",
    ]
  }
  rule {
    api_groups = [
      "cert-manager.io",
    ]
    resources = [
      "issuers",
      "clusterissuers",
    ]
    verbs = [
      "get",
      "list",
      "watch",
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
      "pods",
      "services",
    ]
    verbs = [
      "get",
      "list",
      "watch",
      "create",
      "delete",
    ]
  }
  rule {
    api_groups = [
      "networking.k8s.io",
    ]
    resources = [
      "ingresses",
    ]
    verbs = [
      "get",
      "list",
      "watch",
      "create",
      "delete",
      "update",
    ]
  }
  rule {
    api_groups = [
      "networking.x-k8s.io",
    ]
    resources = [
      "httproutes",
    ]
    verbs = [
      "get",
      "list",
      "watch",
      "create",
      "delete",
      "update",
    ]
  }
  rule {
    api_groups = [
      "route.openshift.io",
    ]
    resources = [
      "routes/custom-host",
    ]
    verbs = [
      "create",
    ]
  }
  rule {
    api_groups = [
      "acme.cert-manager.io",
    ]
    resources = [
      "challenges/finalizers",
    ]
    verbs = [
      "update",
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
}

resource "kubernetes_cluster_role" "controller_ingress_shim" {
  count = var.enabled ? 1 : 0

  metadata {
    name   = local.name_ingressshim
    labels = local.labels_controller
  }

  rule {
    api_groups = [
      "cert-manager.io",
    ]
    resources = [
      "certificates",
      "certificaterequests",
    ]
    verbs = [
      "create",
      "update",
      "delete",
    ]
  }
  rule {
    api_groups = [
      "cert-manager.io",
    ]
    resources = [
      "certificates",
      "certificaterequests",
      "issuers",
      "clusterissuers",
    ]
    verbs = [
      "get",
      "list",
      "watch",
    ]
  }
  rule {
    api_groups = [
      "networking.k8s.io",
    ]
    resources = [
      "ingresses",
    ]
    verbs = [
      "get",
      "list",
      "watch",
    ]
  }
  rule {
    api_groups = [
      "networking.k8s.io",
    ]
    resources = [
      "ingresses/finalizers",
    ]
    verbs = [
      "update",
    ]
  }
  rule {
    api_groups = [
      "networking.x-k8s.io",
    ]
    resources = [
      "gateways",
      "httproutes",
    ]
    verbs = [
      "get",
      "list",
      "watch",
    ]
  }
  rule {
    api_groups = [
      "networking.x-k8s.io",
    ]
    resources = [
      "gateways/finalizers",
      "httproutes/finalizers",
    ]
    verbs = [
      "update",
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
}

resource "kubernetes_cluster_role" "view" {
  count = var.enabled ? 1 : 0

  metadata {
    name = local.name_view
    labels = merge(local.labels_controller, {
      "rbac.authorization.k8s.io/aggregate-to-admin" = "true"
      "rbac.authorization.k8s.io/aggregate-to-edit"  = "true"
      "rbac.authorization.k8s.io/aggregate-to-view"  = "true"
    })
  }

  rule {
    api_groups = [
      "cert-manager.io",
    ]
    resources = [
      "certificates",
      "certificaterequests",
      "issuers",
    ]
    verbs = [
      "get",
      "list",
      "watch",
    ]
  }
  rule {
    api_groups = [
      "acme.cert-manager.io",
    ]
    resources = [
      "challenges",
      "orders",
    ]
    verbs = [
      "get",
      "list",
      "watch",
    ]
  }
}


resource "kubernetes_cluster_role" "edit" {
  count = var.enabled ? 1 : 0

  metadata {
    name = local.name_edit
    labels = merge(local.labels_controller, {
      "rbac.authorization.k8s.io/aggregate-to-admin" = "true"
      "rbac.authorization.k8s.io/aggregate-to-edit"  = "true"
    })
  }

  rule {
    api_groups = [
      "cert-manager.io",
    ]
    resources = [
      "certificates",
      "certificaterequests",
      "issuers",
    ]
    verbs = [
      "create",
      "delete",
      "deletecollection",
      "patch",
      "update",
    ]
  }
  rule {
    api_groups = [
      "acme.cert-manager.io",
    ]
    resources = [
      "challenges",
      "orders",
    ]
    verbs = [
      "create",
      "delete",
      "deletecollection",
      "patch",
      "update",
    ]
  }
}

resource "kubernetes_cluster_role" "controller_approve" {
  count = var.enabled ? 1 : 0

  metadata {
    name   = local.name_approve
    labels = local.labels_certmgr
  }

  rule {
    api_groups = [
      "cert-manager.io",
    ]
    resource_names = [
      "issuers.cert-manager.io/*",
      "clusterissuers.cert-manager.io/*",
    ]
    resources = [
      "signers",
    ]
    verbs = [
      "approve",
    ]
  }
}


resource "kubernetes_cluster_role" "controller_certificatesigningrequests" {
  count = var.enabled ? 1 : 0

  metadata {
    name   = local.name_csr
    labels = local.labels_certmgr
  }

  rule {
    api_groups = [
      "certificates.k8s.io",
    ]
    resources = [
      "certificatesigningrequests",
    ]
    verbs = [
      "get",
      "list",
      "watch",
      "update",
    ]
  }
  rule {
    api_groups = [
      "certificates.k8s.io",
    ]
    resources = [
      "certificatesigningrequests/status",
    ]
    verbs = [
      "update",
    ]
  }
  rule {
    api_groups = [
      "certificates.k8s.io",
    ]
    resource_names = [
      "issuers.cert-manager.io/*",
      "clusterissuers.cert-manager.io/*",
    ]
    resources = [
      "signers",
    ]
    verbs = [
      "sign",
    ]
  }
  rule {
    api_groups = [
      "authorization.k8s.io",
    ]
    resources = [
      "subjectaccessreviews",
    ]
    verbs = [
      "create",
    ]
  }
}

resource "kubernetes_cluster_role" "subjectaccessreviews" {
  count = var.enabled ? 1 : 0

  metadata {
    name   = local.name_sar
    labels = local.labels_webhook
  }

  rule {
    api_groups = [
      "authorization.k8s.io",
    ]
    resources = [
      "subjectaccessreviews",
    ]
    verbs = [
      "create",
    ]
  }
}

resource "kubernetes_cluster_role_binding" "cainjector" {
  count = var.enabled ? 1 : 0

  metadata {
    name   = local.name_cainjector
    labels = local.labels_cainjector
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.cainjector[0].metadata[0].name
  }
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.cainjector[0].metadata[0].name
    namespace = kubernetes_service_account.cainjector[0].metadata[0].namespace
  }
}

resource "kubernetes_cluster_role_binding" "issuers" {
  count = var.enabled ? 1 : 0

  metadata {
    name   = local.name_issuers
    labels = local.labels_controller
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.issuers[0].metadata[0].name
  }
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.cert_manager[0].metadata[0].name
    namespace = kubernetes_service_account.cert_manager[0].metadata[0].namespace
  }
}

resource "kubernetes_cluster_role_binding" "clusterissuers" {
  count = var.enabled ? 1 : 0

  metadata {
    name   = local.name_clusterissuers
    labels = local.labels_controller
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.clusterissuers[0].metadata[0].name
  }
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.cert_manager[0].metadata[0].name
    namespace = kubernetes_service_account.cert_manager[0].metadata[0].namespace
  }
}

resource "kubernetes_cluster_role_binding" "controller_certificates" {
  count = var.enabled ? 1 : 0

  metadata {
    name   = local.name_certificates
    labels = local.labels_controller
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.controller_certificates[0].metadata[0].name
  }
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.cert_manager[0].metadata[0].name
    namespace = kubernetes_service_account.cert_manager[0].metadata[0].namespace
  }
}

resource "kubernetes_cluster_role_binding" "controller_orders" {
  count = var.enabled ? 1 : 0

  metadata {
    name   = local.name_orders
    labels = local.labels_controller
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.controller_orders[0].metadata[0].name
  }
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.cert_manager[0].metadata[0].name
    namespace = kubernetes_service_account.cert_manager[0].metadata[0].namespace
  }
}

resource "kubernetes_cluster_role_binding" "controller_challenges" {
  count = var.enabled ? 1 : 0

  metadata {
    name   = local.name_challenges
    labels = local.labels_controller
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.controller_challenges[0].metadata[0].name
  }
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.cert_manager[0].metadata[0].name
    namespace = kubernetes_service_account.cert_manager[0].metadata[0].namespace
  }
}

resource "kubernetes_cluster_role_binding" "ontroller_ingress_shim" {
  count = var.enabled ? 1 : 0

  metadata {
    name   = local.name_ingressshim
    labels = local.labels_controller
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.controller_ingress_shim[0].metadata[0].name
  }
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.cert_manager[0].metadata[0].name
    namespace = kubernetes_service_account.cert_manager[0].metadata[0].namespace
  }
}

resource "kubernetes_cluster_role_binding" "controller_approve" {
  count = var.enabled ? 1 : 0

  metadata {
    name   = local.name_approve
    labels = local.labels_controller
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.controller_approve[0].metadata[0].name
  }
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.cert_manager[0].metadata[0].name
    namespace = kubernetes_service_account.cert_manager[0].metadata[0].namespace
  }
}

resource "kubernetes_cluster_role_binding" "controller_certificatesigningrequests" {
  count = var.enabled ? 1 : 0

  metadata {
    name   = local.name_csr
    labels = local.labels_controller
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.controller_certificatesigningrequests[0].metadata[0].name
  }
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.cert_manager[0].metadata[0].name
    namespace = kubernetes_service_account.cert_manager[0].metadata[0].namespace
  }
}

resource "kubernetes_cluster_role_binding" "subjectaccessreviews" {
  count = var.enabled ? 1 : 0

  metadata {
    name   = local.name_sar
    labels = local.labels_webhook
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.subjectaccessreviews[0].metadata[0].name
  }
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.webhook[0].metadata[0].name
    namespace = kubernetes_service_account.webhook[0].metadata[0].namespace
  }
}

resource "kubernetes_role" "cainjector_leaderelection" {
  count = var.enabled ? 1 : 0

  metadata {
    name      = "${local.name_cainjector}:leaderelection"
    namespace = "kube-system"
    labels    = local.labels_cainjector
  }
  rule {
    api_groups = [
      "",
    ]
    resource_names = [
      "cert-manager-cainjector-leader-election",
      "cert-manager-cainjector-leader-election-core",
    ]
    resources = [
      "configmaps",
    ]
    verbs = [
      "get",
      "update",
      "patch",
    ]
  }
  rule {
    api_groups = [
      "",
    ]
    resources = [
      "configmaps",
    ]
    verbs = [
      "create",
    ]
  }
  rule {
    api_groups = [
      "coordination.k8s.io",
    ]
    resource_names = [
      "cert-manager-cainjector-leader-election",
      "cert-manager-cainjector-leader-election-core",
    ]
    resources = [
      "leases",
    ]
    verbs = [
      "get",
      "update",
      "patch",
    ]
  }
  rule {
    api_groups = [
      "coordination.k8s.io",
    ]
    resources = [
      "leases",
    ]
    verbs = [
      "create",
    ]
  }
}

resource "kubernetes_role" "cert_manager_leaderelection" {
  count = var.enabled ? 1 : 0

  metadata {
    name      = "${local.name_certmgr}:leaderelection"
    namespace = "kube-system"
    labels    = local.labels_controller
  }
  rule {
    api_groups = [
      "",
    ]
    resource_names = [
      "cert-manager-controller",
    ]
    resources = [
      "configmaps",
    ]
    verbs = [
      "get",
      "update",
      "patch",
    ]
  }
  rule {
    api_groups = [
      "",
    ]
    resources = [
      "configmaps",
    ]
    verbs = [
      "create",
    ]
  }
  rule {
    api_groups = [
      "coordination.k8s.io",
    ]
    resource_names = [
      "cert-manager-controller",
    ]
    resources = [
      "leases",
    ]
    verbs = [
      "get",
      "update",
      "patch",
    ]
  }
  rule {
    api_groups = [
      "coordination.k8s.io",
    ]
    resources = [
      "leases",
    ]
    verbs = [
      "create",
    ]
  }
}

resource "kubernetes_role" "webhook_dynamic_serving" {
  count = var.enabled ? 1 : 0

  metadata {
    name      = "${local.name_webhook}:dynamic-serving"
    namespace = var.namespace
    labels    = local.labels_webhook
  }
  rule {
    api_groups = [
      "",
    ]
    resource_names = [
      "${var.system_name}-cert-manager-webhook-ca",
    ]
    resources = [
      "secrets",
    ]
    verbs = [
      "get",
      "list",
      "watch",
      "update",
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
      "create",
    ]
  }


}

resource "kubernetes_role_binding" "cainjector_leaderelection" {
  count = var.enabled ? 1 : 0

  metadata {
    name      = "${local.name_cainjector}:leaderelection"
    namespace = "kube-system"
    labels    = local.labels_cainjector
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role.cainjector_leaderelection[0].metadata[0].name
  }
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.cainjector[0].metadata[0].name
    namespace = kubernetes_service_account.cainjector[0].metadata[0].namespace
  }
}

resource "kubernetes_role_binding" "cert_manager_leaderelection" {
  count = var.enabled ? 1 : 0

  metadata {
    name      = "${local.name_certmgr}:leaderelection"
    namespace = "kube-system"
    labels    = local.labels_controller
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role.cert_manager_leaderelection[0].metadata[0].name
  }
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.cert_manager[0].metadata[0].name
    namespace = kubernetes_service_account.cert_manager[0].metadata[0].namespace
  }
}

resource "kubernetes_role_binding" "webhook_dynamic_serving" {
  count = var.enabled ? 1 : 0

  metadata {
    name      = "${local.name_webhook}:dynamic-serving"
    namespace = var.namespace
    labels    = local.labels_webhook
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role.webhook_dynamic_serving[0].metadata[0].name
  }
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.webhook[0].metadata[0].name
    namespace = kubernetes_service_account.webhook[0].metadata[0].namespace
  }
}

resource "kubernetes_service" "cert_manager" {
  count = var.enabled ? 1 : 0

  metadata {
    name      = local.name_certmgr
    namespace = kubernetes_namespace.cert_manager[0].metadata[0].name
    labels    = local.labels_controller
  }
  spec {
    port {
      name        = "tcp-prometheus-servicemonitor"
      port        = 9402
      protocol    = "TCP"
      target_port = 9402
    }
    selector = {
      "app.kubernetes.io/component" = "controller"
      "app.kubernetes.io/instance"  = var.system_name
      "app.kubernetes.io/name"      = "cert-manager"
    }
    type = "ClusterIP"
  }
}

resource "kubernetes_service" "webhook" {
  count = var.enabled ? 1 : 0

  metadata {
    name      = local.name_webhook
    namespace = kubernetes_namespace.cert_manager[0].metadata[0].name
    labels    = local.labels_webhook
  }
  spec {
    port {
      name        = "https"
      port        = 443
      protocol    = "TCP"
      target_port = 10250
    }
    selector = {
      "app.kubernetes.io/component" = "webhook"
      "app.kubernetes.io/instance"  = var.system_name
      "app.kubernetes.io/name"      = "webhook"
    }
    type = "ClusterIP"
  }
}

resource "kubernetes_deployment" "cainjector" {
  count = var.enabled ? 1 : 0

  metadata {
    name      = local.name_cainjector
    namespace = kubernetes_namespace.cert_manager[0].metadata[0].name
    labels    = local.labels_cainjector
  }
  spec {
    replicas = var.replicas_cainjector
    selector {
      match_labels = {
        "app.kubernetes.io/component" = "cainjector"
        "app.kubernetes.io/instance"  = var.system_name
        "app.kubernetes.io/name"      = "cainjector"
      }
    }
    template {
      metadata {
        labels = local.labels_cainjector
      }
      spec {
        container {
          args = [
            "--v=2",
            "--leader-election-namespace=kube-system",
          ]
          env {
            name = "POD_NAMESPACE"
            value_from {
              field_ref {
                field_path = "metadata.namespace"
              }
            }
          }
          image             = var.image_cainjector
          image_pull_policy = "IfNotPresent"
          name              = "cert-manager"
          resources {
            limits   = var.resources_cainjector.limits
            requests = var.resources_cainjector.requests
          }
        }
        security_context {
          run_as_non_root = true
        }
        service_account_name = kubernetes_service_account.cainjector[0].metadata[0].name
      }
    }
  }
}

resource "kubernetes_deployment" "cert_manager" {
  count = var.enabled ? 1 : 0

  metadata {
    name      = local.name_certmgr
    namespace = kubernetes_namespace.cert_manager[0].metadata[0].name
    labels    = local.labels_controller
  }
  spec {
    replicas = var.replicas_controller
    selector {
      match_labels = {
        "app.kubernetes.io/component" = "controller"
        "app.kubernetes.io/instance"  = var.system_name
        "app.kubernetes.io/name"      = "cert-manager"
      }
    }
    template {
      metadata {
        labels      = local.labels_controller
        annotations = local.certmgr_metrics_annotations
      }
      spec {
        container {
          args = [
            "--v=2",
            "--cluster-resource-namespace=$(POD_NAMESPACE)",
            "--leader-election-namespace=kube-system",
          ]
          env {
            name = "POD_NAMESPACE"
            value_from {
              field_ref {
                field_path = "metadata.namespace"
              }
            }
          }
          image             = var.image_controller
          image_pull_policy = "IfNotPresent"
          name              = "cert-manager"
          port {
            container_port = 9402
            protocol       = "TCP"
          }
          resources {
            limits   = var.resources_controller.limits
            requests = var.resources_controller.requests
          }
        }
        security_context {
          run_as_non_root = true
        }
        service_account_name = kubernetes_service_account.cert_manager[0].metadata[0].name
      }
    }
  }
}

resource "kubernetes_deployment" "webhook" {
  count = var.enabled ? 1 : 0

  metadata {
    name      = local.name_webhook
    namespace = kubernetes_namespace.cert_manager[0].metadata[0].name
    labels    = local.labels_webhook
  }
  spec {
    replicas = var.replicas_webhook
    selector {
      match_labels = {
        "app.kubernetes.io/component" = "webhook"
        "app.kubernetes.io/instance"  = var.system_name
        "app.kubernetes.io/name"      = "webhook"
      }
    }
    template {
      metadata {
        labels = local.labels_webhook
      }
      spec {
        container {
          args = [
            "--v=2",
            "--secure-port=10250",
            "--dynamic-serving-ca-secret-namespace=$(POD_NAMESPACE)",
            "--dynamic-serving-ca-secret-name=${local.name_webhook}-ca",
            "--dynamic-serving-dns-names=${local.name_webhook},${local.name_webhook}.${var.namespace},${local.name_webhook}.${var.namespace}.svc",
          ]
          env {
            name = "POD_NAMESPACE"
            value_from {
              field_ref {
                field_path = "metadata.namespace"
              }
            }
          }
          image             = var.image_webhook
          image_pull_policy = "IfNotPresent"
          liveness_probe {
            failure_threshold = 3
            http_get {
              path   = "/livez"
              port   = 6080
              scheme = "HTTP"
            }
            initial_delay_seconds = 60
            period_seconds        = 10
            success_threshold     = 1
            timeout_seconds       = 1
          }
          name = "cert-manager"
          port {
            container_port = 10250
            name           = "https"
            protocol       = "TCP"
          }
          readiness_probe {
            failure_threshold = 3
            http_get {
              path   = "/healthz"
              port   = 6080
              scheme = "HTTP"
            }
            initial_delay_seconds = 5
            period_seconds        = 5
            success_threshold     = 1
            timeout_seconds       = 1
          }
          resources {
            limits   = var.resources_webhook.limits
            requests = var.resources_webhook.requests
          }
        }
        security_context {
          run_as_non_root = true
        }
        service_account_name = kubernetes_service_account.webhook[0].metadata[0].name
      }
    }
  }
}

resource "kubernetes_mutating_webhook_configuration" "cert-manager-webhook" {
  count = var.enabled ? 1 : 0

  metadata {
    name   = local.name_webhook
    labels = local.labels_webhook
    annotations = {
      "cert-manager.io/inject-ca-from-secret" = "${var.namespace}/${local.name_webhook}-ca"
    }
  }
  webhook {
    admission_review_versions = [
      "v1",
      "v1beta1",
    ]
    client_config {
      service {
        name      = local.name_webhook
        namespace = kubernetes_namespace.cert_manager[0].metadata[0].name
        path      = "/mutate"
      }
    }
    failure_policy = "Fail"
    match_policy   = "Equivalent"
    name           = "webhook.cert-manager.io"
    rule {
      api_groups = [
        "cert-manager.io",
        "acme.cert-manager.io",
      ]
      api_versions = [
        "v1",
      ]
      operations = [
        "CREATE",
        "UPDATE",
      ]
      resources = [
        "*/*",
      ]
    }
    side_effects    = "None"
    timeout_seconds = 10
  }
}

resource "kubernetes_validating_webhook_configuration" "cert-manager-webhook" {
  count = var.enabled ? 1 : 0

  metadata {
    name   = local.name_webhook
    labels = local.labels_webhook
    annotations = {
      "cert-manager.io/inject-ca-from-secret" = "${var.namespace}/${local.name_webhook}-ca"
    }
  }
  webhook {
    admission_review_versions = [
      "v1",
      "v1beta1",
    ]
    client_config {
      service {
        name      = local.name_webhook
        namespace = kubernetes_namespace.cert_manager[0].metadata[0].name
        path      = "/validate"
      }
    }
    failure_policy = "Fail"
    match_policy   = "Equivalent"
    name           = "webhook.cert-manager.io"
    namespace_selector {
      match_expressions {
        key      = "cert-manager.io/disable-validation"
        operator = "NotIn"
        values = [
          "true",
        ]
      }
      match_expressions {
        key      = "name"
        operator = "NotIn"
        values = [
          var.namespace,
        ]
      }
    }
    rule {
      api_groups = [
        "cert-manager.io",
        "acme.cert-manager.io",
      ]
      api_versions = [
        "v1",
      ]
      operations = [
        "CREATE",
        "UPDATE",
      ]
      resources = [
        "*/*",
      ]
    }
    side_effects    = "None"
    timeout_seconds = 10
  }
}

resource "kubernetes_service_account" "startupapicheck" {
  count = var.enabled ? 1 : 0

  metadata {
    name      = local.name_startupcheck
    namespace = kubernetes_namespace.cert_manager[0].metadata[0].name
    labels    = local.labels_startup
  }
  automount_service_account_token = true
}

resource "kubernetes_role" "startupapicheck_create_cert" {
  count = var.enabled ? 1 : 0

  metadata {
    name      = "${local.name_startupcheck}:create-cert"
    namespace = kubernetes_namespace.cert_manager[0].metadata[0].name
    labels    = local.labels_startup
  }
  rule {
    api_groups = [
      "cert-manager.io",
    ]
    resources = [
      "certificates",
    ]
    verbs = [
      "create",
    ]
  }
}

resource "kubernetes_role_binding" "startupapicheck_create_cert" {
  count = var.enabled ? 1 : 0

  metadata {
    name      = "${local.name_startupcheck}:create-cert"
    namespace = kubernetes_namespace.cert_manager[0].metadata[0].name
    labels    = local.labels_startup
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role.startupapicheck_create_cert[0].metadata[0].name
  }
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.startupapicheck[0].metadata[0].name
    namespace = kubernetes_service_account.startupapicheck[0].metadata[0].namespace
  }
}

resource "kubernetes_job" "startupapicheck" {
  count = var.enabled ? 1 : 0

  metadata {
    name      = local.name_startupcheck
    namespace = kubernetes_namespace.cert_manager[0].metadata[0].name
    labels    = local.labels_startup
  }
  spec {
    backoff_limit = 4
    template {
      metadata {
        labels = local.labels_startup
      }
      spec {
        container {
          args = [
            "check",
            "api",
            "--wait=1m",
          ]
          image             = var.image_startup
          image_pull_policy = "IfNotPresent"
          name              = "cert-manager"
          resources {
            limits   = var.resources_startupapicheck.limits
            requests = var.resources_startupapicheck.requests
          }
        }
        restart_policy = "OnFailure"
        security_context {
          run_as_non_root = true
          fs_group        = 1001
        }
        service_account_name = kubernetes_service_account.startupapicheck[0].metadata[0].name
      }
    }
  }
  wait_for_completion = false

  depends_on = [kubernetes_deployment.cainjector, kubernetes_deployment.cert_manager, kubernetes_deployment.webhook]
}
