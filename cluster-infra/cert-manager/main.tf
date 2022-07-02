module "helm_addon" {
  count = var.enabled ? 1 : 0

  source            = "github.com/aws-ia/terraform-aws-eks-blueprints//modules/kubernetes-addons/helm-addon?ref=v4.2.1"
  manage_via_gitops = false
  set_values        = local.set_values
  helm_config       = local.helm_config
  irsa_config       = local.irsa_config
  addon_context     = local.addon_context
}

resource "helm_release" "cert_manager_ca" {
  count = var.enabled ? 1 : 0

  name      = "cert-manager-ca"
  chart     = "${path.module}/cert-manager-ca"
  version   = "0.2.0"
  namespace = local.helm_config["namespace"]

  depends_on = [module.helm_addon]
}

resource "helm_release" "cert_manager_letsencrypt" {
  count     = var.enabled && var.install_letsencrypt_issuers ? 1 : 0
  name      = "cert-manager-letsencrypt"
  chart     = "${path.module}/cert-manager-letsencrypt"
  version   = "0.1.0"
  namespace = local.helm_config["namespace"]

  set {
    name  = "email"
    value = var.letsencrypt_email
    type  = "string"
  }

  set {
    name  = "dnsZones"
    value = "{${join(",", toset(var.domain_names))}}"
    type  = "string"
  }

  depends_on = [module.helm_addon]
}

resource "aws_iam_policy" "cert_manager" {
  count = var.enabled ? 1 : 0

  description = "cert-manager IAM policy."
  name        = "${local.addon_context.eks_cluster_id}-${local.helm_config["name"]}-irsa"
  path        = local.addon_context.irsa_iam_role_path
  policy      = data.aws_iam_policy_document.cert_manager_iam_policy_document.json
}
