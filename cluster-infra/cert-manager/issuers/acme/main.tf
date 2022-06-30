resource "kubectl_manifest" "issuer_dns01" {
  count = local.enabled_via_dns01 && var.namespace != null ? 1 : 0

  yaml_body = <<YAML
apiVersion: cert-manager.io/v1
kind: Issuer
metadata:
  name: ${local.issuer}
  namespace: ${var.namespace}
spec:
  acme:
    email: ${var.cert_admin_email}
    server: ${var.acme_server}
    privateKeySecretRef:
      name: ${local.ca_secret}
    solvers:
    - selector:
        dnsZones:
        - '${var.route53_hosted_zone_name}'
      dns01:
        cnameStrategy: Follow
        route53:
          region: ${data.aws_region.current.name}
          hostedZoneID: ${data.aws_route53_zone.public.zone_id}
YAML
}

resource "kubectl_manifest" "cluster_issuer_dns01" {
  count = local.enabled_via_dns01 && var.provision_cluster_issuer ? 1 : 0

  yaml_body = <<YAML
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: ${local.cluster_issuer}
spec:
  acme:
    email: ${var.cert_admin_email}
    server: ${var.acme_server}
    privateKeySecretRef:
      name: ${local.ca_secret}
    solvers:
    - selector:
        dnsZones:
        - '${var.route53_hosted_zone_name}'
      dns01:
        cnameStrategy: Follow
        route53:
          region: ${data.aws_region.current.name}
          hostedZoneID: ${data.aws_route53_zone.public.zone_id}
YAML
}

resource "kubectl_manifest" "issuer_http01" {
  count = local.enabled_via_http01 && var.namespace != null ? 1 : 0

  yaml_body = <<YAML
apiVersion: cert-manager.io/v1
kind: Issuer
metadata:
  name: ${local.issuer}
  namespace: ${var.namespace}
spec:
  acme:
    email: ${var.cert_admin_email}
    server: ${var.acme_server}
    privateKeySecretRef:
      name: ${local.ca_secret}
    solvers:
    - http01:
        ingress:
          class: ${var.ingress_class}
          serviceType: NodePort
YAML
}

resource "kubectl_manifest" "cluster_issuer_http01" {
  count = local.enabled_via_http01 && var.provision_cluster_issuer ? 1 : 0

  yaml_body = <<YAML
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: ${local.cluster_issuer}
spec:
  acme:
    email: ${var.cert_admin_email}
    server: ${var.acme_server}
    privateKeySecretRef:
      name: ${local.ca_secret}
    solvers:
    - http01:
        ingress:
          class: ${var.ingress_class}
          serviceType: NodePort
YAML
}
