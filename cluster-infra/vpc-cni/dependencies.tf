data "aws_subnet" "pod" {
  for_each = toset(var.pod_subnets)

  id = each.value
}

data "aws_vpc" "selected" {
  id = var.vpc_id
}

data "aws_eks_cluster" "cluster" {
  name = var.cluster_name
}

data "aws_eks_cluster_auth" "cluster" {
  name = var.cluster_name
}

data "external" "cni_cfg" {
  count = var.enabled ? 1 : 0

  program = ["${path.module}/scripts/check-cni-config.sh"]
  query = {
    kubeserver = data.aws_eks_cluster.cluster.endpoint
    kubetoken  = data.aws_eks_cluster_auth.cluster.token
    kubeca     = local_file.kube_ca[0].filename
  }
}
