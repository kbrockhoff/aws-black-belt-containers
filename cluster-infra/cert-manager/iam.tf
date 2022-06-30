data "aws_iam_policy_document" "acme_issuer_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(var.cluster_oidc_issuer_url, "https://", "")}:sub"
      values   = ["system:serviceaccount:${var.namespace}:${local.name_certmgr}"]
    }

    principals {
      identifiers = [var.oidc_provider_arn]
      type        = "Federated"
    }
  }
}

resource "aws_iam_role" "acme_issuer" {
  count = local.enabled_dns01 ? 1 : 0

  assume_role_policy = data.aws_iam_policy_document.acme_issuer_assume_role_policy.json
  name               = "${local.name_certmgr}-sa"

  tags = merge(var.tags, {
    Name = "${local.name_certmgr}-sa"
  })
}

data "aws_iam_policy_document" "route53" {
  statement {
    effect = "Allow"
    actions = [
      "route53:GetChange",
    ]
    resources = [
      "arn:aws:route53:::change/*",
    ]
  }
  statement {
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
  count = local.enabled_dns01 ? 1 : 0

  name   = "${local.name_certmgr}-route53-policy"
  policy = data.aws_iam_policy_document.route53.json
}

resource "aws_iam_role_policy_attachment" "route53" {
  count = local.enabled_dns01 ? 1 : 0

  policy_arn = aws_iam_policy.route53[0].arn
  role       = aws_iam_role.acme_issuer[0].name
}
