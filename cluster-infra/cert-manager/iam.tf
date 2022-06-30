data "aws_iam_policy_document" "certmgr_assume_role" {
  count = var.enabled ? 1 : 0

  statement {
    effect = "Allow"
    principals {
      identifiers = [var.oidc_provider_arn]
      type        = "Federated"
    }
    actions = ["sts:AssumeRoleWithWebIdentity"]
    condition {
      test     = "StringEquals"
      variable = "${replace(var.cluster_oidc_issuer_url, "https://", "")}:sub"
      values   = ["system:serviceaccount:${var.namespace}:${local.name_certmgr}"]
    }
  }
}

resource "aws_iam_role" "certmgr" {
  count = var.enabled ? 1 : 0

  assume_role_policy = data.aws_iam_policy_document.certmgr_assume_role[0].json
  name               = local.name_iam

  tags = merge(var.tags, {
    Name = local.name_iam
  })
}

data "aws_iam_policy_document" "route53" {
  count = var.enabled ? 1 : 0

  statement {
    sid    = "Route53Updates"
    effect = "Allow"
    actions = [
      "route53:GetChange",
    ]
    resources = [
      "arn:aws:route53:::change/*",
    ]
  }
  statement {
    sid    = "Route53Updates"
    effect = "Allow"
    actions = [
      "route53:ChangeResourceRecordSets",
      "route53:ListResourceRecordSets",
    ]
    resources = [
      "arn:aws:route53:::hostedzone/*"
    ]
  }
  statement {
    sid    = "Route53Reads"
    effect = "Allow"
    actions = [
      "route53:ListHostedZonesByName",
    ]
    resources = [
      "*",
    ]
  }
}

resource "aws_iam_policy" "route53" {
  count = var.enabled ? 1 : 0

  name   = local.name_iam
  policy = data.aws_iam_policy_document.route53[0].json
}

resource "aws_iam_role_policy_attachment" "route53" {
  count = var.enabled ? 1 : 0

  policy_arn = aws_iam_policy.route53[0].arn
  role       = aws_iam_role.certmgr[0].name
}
