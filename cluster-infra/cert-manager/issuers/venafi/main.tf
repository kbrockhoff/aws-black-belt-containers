resource "kubernetes_secret" "venafi_apikey" {
  count = var.enabled ? 1 : 0

  metadata {
    name      = local.name_secret
    namespace = var.namespace
  }
  type = "Opaque"
  data = {
    apikey = var.venafi_api_key
  }
}

resource "kubectl_manifest" "venafi_issuer" {
  count = var.enabled && local.provision_issuer ? 1 : 0

  yaml_body = <<YAML
apiVersion: cert-manager.io/v1
kind: Issuer
metadata:
  name: ${local.issuer}
  namespace: ${var.namespace}
spec:
  venafi:
    zone: "${var.venafi_zone}"
    cloud:
      apiTokenSecretRef:
        name: ${kubernetes_secret.venafi_apikey[0].metadata[0].name}
        namespace: ${kubernetes_secret.venafi_apikey[0].metadata[0].namespace}
        key: apikey
YAML
}

resource "kubectl_manifest" "venafi_cluster_issuer" {
  count = var.enabled && var.provision_cluster_issuer ? 1 : 0

  yaml_body = <<YAML
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: ${local.cluster_issuer}
spec:
  venafi:
    zone: "${var.venafi_zone}"
    cloud:
      apiTokenSecretRef:
        name: ${kubernetes_secret.venafi_apikey[0].metadata[0].name}
        namespace: ${kubernetes_secret.venafi_apikey[0].metadata[0].namespace}
        key: apikey
YAML
}
