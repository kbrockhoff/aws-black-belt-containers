resource "kubectl_manifest" "selfsigner_issuer" {
  count = var.enabled && var.bootstrap_ca ? 1 : 0

  yaml_body = <<YAML
apiVersion: cert-manager.io/v1
kind: Issuer
metadata:
  name: ${local.bootstrap_issuer}
  namespace: ${var.secret_namespace}
spec:
  selfSigned: {}
YAML
}

resource "kubectl_manifest" "signing_cert" {
  count = var.enabled && var.bootstrap_ca && var.provision_cluster_issuer ? 1 : 0

  yaml_body = <<YAML
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: ${local.ca_name}
  namespace: default
spec:
  isCA: true
  commonName: ${local.ca_name}
  secretName: ${local.ca_secret}
  privateKey:
    algorithm: ECDSA
    size: 256
  issuerRef:
    name: ${local.bootstrap_issuer}
    namespace: ${var.secret_namespace}
    kind: Issuer
    group: cert-manager.io
YAML
}

resource "kubectl_manifest" "namespace_signing_cert" {
  count = var.enabled && var.bootstrap_ca && var.namespace != null ? 1 : 0

  yaml_body = <<YAML
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: ${local.ca_name}
  namespace: ${var.namespace}
spec:
  isCA: true
  commonName: ${local.ca_name}
  secretName: ${local.ca_secret}
  privateKey:
    algorithm: ECDSA
    size: 256
  issuerRef:
    name: ${local.bootstrap_issuer}
    namespace: ${var.secret_namespace}
    kind: Issuer
    group: cert-manager.io
YAML
}

resource "kubectl_manifest" "signing_ca_secret" {
  count = var.enabled && var.provision_cluster_issuer && var.ca_key != null ? 1 : 0

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
  count = var.enabled && var.namespace != null && var.ca_key != null ? 1 : 0

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

resource "kubectl_manifest" "issuer" {
  count = var.enabled && var.namespace != null ? 1 : 0

  yaml_body = <<YAML
apiVersion: cert-manager.io/v1
kind: Issuer
metadata:
  name: ${local.issuer}
  namespace: ${var.namespace}
spec:
  ca:
    secretName: ${local.ca_secret}
YAML

  depends_on = [kubectl_manifest.namespace_signing_ca_secret, kubectl_manifest.namespace_signing_cert]
}

resource "kubectl_manifest" "cluster_issuer" {
  count = var.enabled && var.provision_cluster_issuer ? 1 : 0

  yaml_body = <<YAML
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: ${local.cluster_issuer}
spec:
  ca:
    secretName: ${local.ca_secret}
YAML

  depends_on = [kubectl_manifest.signing_ca_secret, kubectl_manifest.signing_cert]
}
