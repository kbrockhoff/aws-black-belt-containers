data "aws_iam_policy_document" "secrets_kms_key" {
  statement {
    sid    = "KeyAdministration"
    effect = "Allow"
    principals {
      type = "AWS"
      identifiers = [
        "arn:${local.partition_id}:iam::${local.account_id}:root",
      ]
    }
    actions = [
      "kms:*",
    ]
    resources = ["*"]
  }
  statement {
    sid    = "SecretsManager"
    effect = "Allow"
    principals {
      type = "AWS"
      identifiers = [
        "*",
      ]
    }
    actions = [
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:CreateGrant",
      "kms:DescribeKey",
    ]
    resources = ["*"]
    condition {
      test     = "StringEquals"
      variable = "kms:ViaService"
      values = [
        "secretsmanager.us.${local.region}.${local.partition_suffix}",
      ]
    }
    condition {
      test     = "StringEquals"
      variable = "kms:CallerAccount"
      values = [
        local.account_id,
      ]
    }
  }
}

resource "aws_kms_key" "secrets" {
  description              = "Encrypts SecretsManager secrets used by the project"
  key_usage                = "ENCRYPT_DECRYPT"
  customer_master_key_spec = "SYMMETRIC_DEFAULT"
  policy                   = data.aws_iam_policy_document.secrets_kms_key.json
  deletion_window_in_days  = 14
  is_enabled               = true
  enable_key_rotation      = true

  tags = merge(module.this.tags, {
    Name = "${module.this.name_prefix}-secrets"
  })
}

resource "aws_secretsmanager_secret" "argocd" {
  name                    = local.admin_secret_name
  description             = "Adminstration password for ArgoCD."
  kms_key_id              = aws_kms_key.secrets.arn
  recovery_window_in_days = 0

  tags = merge(module.this.tags, {
    Name = local.admin_secret_name
  })
}

resource "aws_secretsmanager_secret_version" "argocd" {
  secret_id     = aws_secretsmanager_secret.argocd.id
  secret_string = data.external.pwgen.result.argocdpwd
}

resource "aws_secretsmanager_secret" "github" {
  name                    = local.github_ssh_name
  description             = "Ssh key for accessing repos by ArgoCD."
  kms_key_id              = aws_kms_key.secrets.arn
  recovery_window_in_days = 0

  tags = merge(module.this.tags, {
    Name = local.github_ssh_name
  })
}

resource "aws_secretsmanager_secret_version" "github" {
  secret_id     = aws_secretsmanager_secret.github.id
  secret_string = file(local.private_key_filename)
}
