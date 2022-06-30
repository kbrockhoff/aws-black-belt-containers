resource "kubectl_manifest" "awspca_issuer" {
  count = var.enabled && var.namespace != null ? 1 : 0

  yaml_body = <<YAML
apiVersion: awspca.cert-manager.io/v1beta1
kind: AWSPCAIssuer
metadata:
  name: ${local.issuer}
  namespace: ${var.namespace}
spec:
  arn: ${data.aws_acmpca_certificate_authority.shared[0].arn}
  region: ${data.aws_region.current.id}
YAML

  depends_on = [
    kubectl_manifest.awspca_issuers,
    kubectl_manifest.awspca_cluster_issuers,
  ]
}

resource "kubectl_manifest" "awspca_cluster_issuer" {
  count = var.enabled && var.provision_cluster_issuer ? 1 : 0

  yaml_body = <<YAML
apiVersion: awspca.cert-manager.io/v1beta1
kind: AWSPCAClusterIssuer
metadata:
  name: ${local.cluster_issuer}
spec:
  arn: ${data.aws_acmpca_certificate_authority.shared[0].arn}
  region: ${data.aws_region.current.id}
YAML

  depends_on = [
    kubectl_manifest.awspca_issuers,
    kubectl_manifest.awspca_cluster_issuers,
  ]
}
