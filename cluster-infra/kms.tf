data "aws_iam_policy_document" "logs_kms_key" {
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
    sid    = "Logging"
    effect = "Allow"
    principals {
      type = "Service"
      identifiers = [
        "logs.${var.region}.${local.partition_suffix}",
      ]
    }
    actions = [
      "kms:Encrypt*",
      "kms:Decrypt*",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:Describe*",
    ]
    resources = ["*"]
    condition {
      test     = "ArnLike"
      variable = "kms:EncryptionContext:aws:logs:arn"
      values = [
        "arn:${local.partition_id}:logs:${var.region}:${local.account_id}:*",
      ]
    }
  }
}

resource "aws_kms_key" "logs" {
  description              = "CMK for encrypting EKS logs"
  key_usage                = "ENCRYPT_DECRYPT"
  policy                   = data.aws_iam_policy_document.logs_kms_key.json
  customer_master_key_spec = "SYMMETRIC_DEFAULT"
  deletion_window_in_days  = 14
  is_enabled               = true
  enable_key_rotation      = true

  tags = merge(module.this.tags, {
    Name = local.log_kms_name
  })
}

data "aws_iam_policy_document" "ebs_kms_key" {
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
    sid    = "KeyUsage"
    effect = "Allow"
    principals {
      type = "AWS"
      identifiers = [
        local.cluster_role_arn,
      ]
    }
    actions = [
      "kms:Encrypt*",
      "kms:Decrypt*",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:Describe*",
    ]
    resources = ["*"]
  }
  statement {
    sid    = "KeyAttachment"
    effect = "Allow"
    principals {
      type = "AWS"
      identifiers = [
        local.cluster_role_arn,
      ]
    }
    actions = [
      "kms:CreateGrant",
      "kms:ListGrants",
      "kms:RevokeGrant",
    ]
    resources = ["*"]
    condition {
      test     = "Bool"
      variable = "kms:GrantIsForAWSResource"
      values   = ["true"]
    }
  }
}

resource "aws_kms_key" "ebs" {
  description              = "CMK for encrypting EBS volumes"
  key_usage                = "ENCRYPT_DECRYPT"
  policy                   = data.aws_iam_policy_document.ebs_kms_key.json
  customer_master_key_spec = "SYMMETRIC_DEFAULT"
  deletion_window_in_days  = 14
  is_enabled               = true
  enable_key_rotation      = true

  tags = merge(module.this.tags, {
    Name = local.ebs_kms_name
  })
}
