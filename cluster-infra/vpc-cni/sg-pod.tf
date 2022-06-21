resource "aws_security_group" "pods" {
  count = var.pod_create_security_group && var.enabled ? 1 : 0

  name_prefix = "${var.cluster_name}-eks-pod-"
  description = "Security group for EKS pods in alternate subnets."
  vpc_id      = var.vpc_id
  tags = merge(
    var.tags,
    {
      "Name"                                      = "${var.cluster_name}-eks-pod-sg"
      "kubernetes.io/cluster/${var.cluster_name}" = "owned"
    },
  )
}

resource "aws_security_group_rule" "pods_egress_internet" {
  count = var.pod_create_security_group && var.enabled ? 1 : 0

  description       = "Allow pods all egress to the Internet."
  protocol          = "-1"
  security_group_id = local.pod_security_group_id
  cidr_blocks       = var.pods_egress_cidrs
  from_port         = 0
  to_port           = 0
  type              = "egress"
}

resource "aws_security_group_rule" "pods_ingress_self" {
  count = var.pod_create_security_group && var.enabled ? 1 : 0

  description       = "Allow pods to communicate within the VPC."
  protocol          = "-1"
  security_group_id = local.pod_security_group_id
  cidr_blocks       = local.vpc_cidrs
  from_port         = 0
  to_port           = 65535
  type              = "ingress"
}

resource "aws_security_group_rule" "pods_ingress_cluster_primary" {
  count = var.pod_create_security_group && var.enabled ? 1 : 0

  description              = "Allow pods running on workers to receive communication from cluster primary security group (e.g. Fargate pods)."
  protocol                 = "all"
  security_group_id        = local.pod_security_group_id
  source_security_group_id = var.cluster_security_group_id
  from_port                = 0
  to_port                  = 65535
  type                     = "ingress"
}
