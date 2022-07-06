locals {
  name = "kps"

  default_helm_config = {
    name             = local.name
    chart            = "kube-prometheus-stack"
    repository       = "https://prometheus-community.github.io/helm-charts"
    version          = "36.2.1"
    namespace        = "monitoring"
    create_namespace = false
    values           = local.default_helm_values
    set              = []
    description      = "Community Kubernetes Prometheus Stack configuration"
    wait             = false
  }

  default_helm_values = [templatefile("${path.module}/values.yaml", {})]

  helm_config = merge(
    local.default_helm_config,
    var.helm_config
  )

  promstack_gitops_config = {
    enable = true
  }
}
