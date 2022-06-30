resource "kubectl_manifest" "issuer" {
  count = var.enabled && var.namespace != null ? 1 : 0

  yaml_body = <<YAML
apiVersion: cert-manager.io/v1
kind: Issuer
metadata:
  name: ${local.issuer}
  namespace: ${var.namespace}
spec:
  selfSigned: {}
YAML
}

resource "kubectl_manifest" "cluster_issuer" {
  count = var.enabled && var.provision_cluster_issuer ? 1 : 0

  yaml_body = <<YAML
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: ${local.cluster_issuer}
spec:
  selfSigned: {}
YAML
}
