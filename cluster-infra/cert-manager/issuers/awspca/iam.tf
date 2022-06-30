data "aws_iam_policy_document" "awspca_issuer_assume_role_policy" {
  count = var.enabled ? 1 : 0

  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(var.cluster_oidc_issuer_url, "https://", "")}:sub"
      values   = ["system:serviceaccount:${var.namespace}:${local.name_caissuer}"]
    }

    principals {
      identifiers = [var.oidc_provider_arn]
      type        = "Federated"
    }
  }
}

resource "aws_iam_role" "awspca_issuer" {
  count = var.enabled ? 1 : 0

  assume_role_policy = data.aws_iam_policy_document.awspca_issuer_assume_role_policy[0].json
  name               = "${local.name_caissuer}-sa"

  tags = merge(var.tags, {
    Name = "${local.name_caissuer}-sa"
  })
}

data "aws_iam_policy_document" "awspca_access" {
  count = var.enabled ? 1 : 0

  statement {
    sid    = "awspcaissuer"
    effect = "Allow"
    actions = [
      "acm-pca:DescribeCertificateAuthority",
      "acm-pca:GetCertificate",
      "acm-pca:IssueCertificate",
    ]
    resources = [
      data.aws_acmpca_certificate_authority.shared[0].arn
    ]
  }
}

resource "aws_iam_policy" "awspca_access" {
  count = var.enabled ? 1 : 0

  name   = "${local.name_caissuer}-privateca-policy"
  policy = data.aws_iam_policy_document.awspca_access[0].json
}

resource "aws_iam_role_policy_attachment" "privateca_access" {
  count = var.enabled ? 1 : 0

  policy_arn = aws_iam_policy.awspca_access[0].arn
  role       = aws_iam_role.awspca_issuer[0].name
}
