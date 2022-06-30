module "selfsigned_issuer" {
  source = "./issuers/selfsign"

  enabled                  = local.enabled_selfsign
  cluster_name             = var.cluster_name
  provision_cluster_issuer = true
  namespace                = null

  depends_on = [
    kubectl_manifest.cluster_issuers,
    kubectl_manifest.issuers,
    kubernetes_service.webhook,
    kubernetes_deployment.webhook,
  ]
}

module "ca_issuer" {
  source = "./issuers/ca"

  enabled                  = local.enabled_ca
  cluster_name             = var.cluster_name
  bootstrap_ca             = local.bootstrap_ca
  provision_cluster_issuer = true
  namespace                = null
  ca_certificate           = var.ca_certificate
  ca_key                   = var.ca_key

  depends_on = [
    kubectl_manifest.cluster_issuers,
    kubectl_manifest.issuers,
    kubernetes_service.webhook,
    kubernetes_deployment.webhook,
  ]
}

module "acme_issuer" {
  source = "./issuers/acme"

  enabled                  = local.enabled_acme
  cluster_name             = var.cluster_name
  provision_cluster_issuer = true
  namespace                = null
  secret_namespace         = null
  acme_challenge_method    = var.acme_challenge_method
  cert_admin_email         = var.cert_admin_email
  acme_server              = var.acme_server
  route53_hosted_zone_name = var.route53_hosted_zone_name

  depends_on = [
    kubectl_manifest.cluster_issuers,
    kubectl_manifest.issuers,
    kubernetes_service.webhook,
    kubernetes_deployment.webhook,
  ]
}

module "awspca_issuer" {
  source = "./issuers/awspca"

  enabled                                = local.enabled_acm
  install_crds                           = var.install_crds
  cluster_name                           = var.cluster_name
  provision_cluster_issuer               = true
  namespace                              = var.namespace
  system_name                            = var.system_name
  cluster_oidc_issuer_url                = var.cluster_oidc_issuer_url
  oidc_provider_arn                      = var.oidc_provider_arn
  awspca_privateca_arn                   = var.awspca_privateca_arn
  cert_manager_service_account_name      = kubernetes_service_account.cert_manager[0].metadata[0].name
  cert_manager_service_account_namespace = kubernetes_service_account.cert_manager[0].metadata[0].namespace
  tags                                   = var.tags

  depends_on = [
    kubectl_manifest.cluster_issuers,
    kubectl_manifest.issuers,
    kubernetes_service.webhook,
    kubernetes_deployment.webhook,
  ]
}

module "venafi_issuer" {
  source = "./issuers/venafi"

  enabled                  = local.enabled_venafi
  cluster_name             = var.cluster_name
  provision_cluster_issuer = true
  namespace                = var.namespace
  system_name              = var.system_name
  venafi_api_key           = var.venafi_api_key
  venafi_zone              = var.venafi_zone
  tags                     = var.tags

  depends_on = [
    kubectl_manifest.cluster_issuers,
    kubectl_manifest.issuers,
    kubernetes_service.webhook,
    kubernetes_deployment.webhook,
  ]
}
