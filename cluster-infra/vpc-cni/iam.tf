
data "aws_iam_policy_document" "aws_node_irsa" {
  count = var.enabled ? 1 : 0

  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(var.cluster_oidc_issuer_url, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:aws-node"]
    }

    principals {
      identifiers = [var.oidc_provider_arn]
      type        = "Federated"
    }
  }
}

resource "aws_iam_role" "aws_node_irsa" {
  count = var.enabled ? 1 : 0

  assume_role_policy = data.aws_iam_policy_document.aws_node_irsa[0].json
  name               = local.vpccnirole_name
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
  ]

  tags = merge(var.tags, {
    Name = local.vpccnirole_name
  })
}
