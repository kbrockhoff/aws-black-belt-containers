data "aws_iam_policy_document" "cni_assume_role_policy" {
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

resource "aws_iam_role" "vpc_cni" {
  count = var.enabled ? 1 : 0

  assume_role_policy = data.aws_iam_policy_document.cni_assume_role_policy.json
  name               = "${var.cluster_name}-vpc-cni"

  tags = merge(var.tags, {
    Name = "${var.cluster_name}-vpc-cni"
  })
}

resource "aws_iam_role_policy_attachment" "vpc_cni" {
  count = var.enabled ? 1 : 0

  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = join("", aws_iam_role.vpc_cni.*.name)
}
