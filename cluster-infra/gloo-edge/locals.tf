locals {
  name = "gloo"

  default_helm_config = {
    name             = local.name
    chart            = local.name
    repository       = "https://storage.googleapis.com/solo-public-helm"
    version          = "1.11.18"
    namespace        = "gloo-system"
    create_namespace = false
    values           = local.default_helm_values
    set              = []
    description      = "Gloo Edge configuration"
    wait             = false
  }

  default_helm_values = [templatefile("${path.module}/values.yaml", {})]

  helm_config = merge(
    local.default_helm_config,
    var.helm_config
  )

  argocd_gitops_config = {
    enable = true
  }
}
