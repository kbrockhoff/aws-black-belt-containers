data "aws_partition" "current" {}

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_iam_session_context" "current" {
  arn = data.aws_caller_identity.current.arn
}

data "aws_vpc" "shared" {
  tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
  }
}

data "aws_subnets" "node" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.shared.id]
  }
  tags = {
    "dbs-networktags" = "private"
  }
}

data "aws_subnet" "node" {
  for_each = toset(data.aws_subnets.node.ids)

  id = each.value
}

data "aws_subnets" "pod" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.shared.id]
  }
  tags = {
    "dbs-networktags" = "pods"
  }
}

data "aws_subnets" "lb" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.shared.id]
  }
  tags = {
    "dbs-networktags" = "public"
  }
}

data "aws_subnet" "lb" {
  for_each = toset(data.aws_subnets.lb.ids)

  id = each.value
}

data "aws_security_group" "lb" {
  vpc_id = data.aws_vpc.shared.id
  tags = {
    "Name" = "dl-aws-k8strng-sbox-bbckb-lb-sg"
  }
}

data "aws_eks_addon_version" "latest" {
  for_each = toset(["vpc-cni", "coredns", "aws-ebs-csi-driver"])

  addon_name         = each.value
  kubernetes_version = module.eks_blueprints.eks_cluster_version
  most_recent        = true
}

data "aws_eks_addon_version" "default" {
  for_each = toset(["kube-proxy"])

  addon_name         = each.value
  kubernetes_version = module.eks_blueprints.eks_cluster_version
  most_recent        = false
}

data "aws_ssm_parameter" "publiczoneid" {
  name     = "/dbs/aft/publiczoneid"
  provider = aws.use2
}

data "aws_route53_zone" "public" {
  zone_id = data.aws_ssm_parameter.publiczoneid.value
}

data "aws_iam_role" "administrator" {
  name = var.sso_administrator_role_name
}

data "aws_iam_role" "poweruser" {
  name = var.sso_poweruser_role_name
}

data "aws_iam_role" "readonly" {
  name = var.sso_readonly_role_name
}

data "aws_iam_role" "github" {
  name = var.github_role_name
}
