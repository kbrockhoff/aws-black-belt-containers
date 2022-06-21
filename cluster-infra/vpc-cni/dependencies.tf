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
