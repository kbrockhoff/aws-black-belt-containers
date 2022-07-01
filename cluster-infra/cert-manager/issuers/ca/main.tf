resource "kubectl_manifest" "signing_ca_secret" {
  count = var.enabled && var.provision_cluster_issuer ? 1 : 0

  yaml_body = <<YAML
apiVersion: v1
kind: Secret
metadata:
  name: ${local.ca_secret}
  namespace: cert-manager
type: kubernetes.io/tls
data:
  tls.crt: '${var.ca_certificate}'
  tls.key: '${var.ca_key}'
YAML
}

resource "kubectl_manifest" "namespace_signing_ca_secret" {
  count = var.enabled && var.namespace != null ? 1 : 0

  yaml_body = <<YAML
apiVersion: v1
kind: Secret
metadata:
  name: ${local.ca_secret}
  namespace: ${var.namespace}
type: kubernetes.io/tls
data:
  tls.crt: ${var.ca_certificate}
  tls.key: ${var.ca_key}
YAML
}
