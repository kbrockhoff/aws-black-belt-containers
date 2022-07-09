data "aws_iam_policy_document" "backups_storage" {
  statement {
    sid    = "VeleroMeta"
    effect = "Allow"
    principals {
      type = "AWS"
      identifiers = [
        local.backup_iam_role,
      ]
    }
    actions = [
      "s3:ListBucket",
      "s3:GetBucketAcl",
    ]
    resources = [
      "arn:aws:s3:::${local.backups_bucket_name}",
    ]
  }
  statement {
    sid    = "VeleroWrite"
    effect = "Allow"
    principals {
      type = "AWS"
      identifiers = [
        local.backup_iam_role,
      ]
    }
    actions = [
      "s3:GetObject",
      "s3:DeleteObject",
      "s3:PutObject",
      "s3:AbortMultipartUpload",
      "s3:ListMultipartUploadParts",
    ]
    resources = [
      "arn:aws:s3:::${local.backups_bucket_name}/*",
    ]
  }
}

resource "aws_s3_bucket" "backups" {
  count = local.create_backups_bucket ? 1 : 0

  bucket        = local.backups_bucket_name
  force_destroy = true

  tags = merge(module.this.tags, {
    Name = local.backups_bucket_name
  })

  lifecycle {
    ignore_changes = [server_side_encryption_configuration]
  }
}

resource "aws_s3_bucket_policy" "backups" {
  count = local.create_backups_bucket ? 1 : 0

  bucket = aws_s3_bucket.backups[0].id
  policy = data.aws_iam_policy_document.backups_storage.json
}

resource "aws_s3_bucket_acl" "backups" {
  count = local.create_backups_bucket ? 1 : 0

  bucket = aws_s3_bucket.backups[0].id
  acl    = "private"
}

resource "aws_s3_bucket_public_access_block" "backups" {
  count = local.create_backups_bucket ? 1 : 0

  bucket                  = aws_s3_bucket.backups[0].id
  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_lifecycle_configuration" "backups" {
  count = local.create_backups_bucket ? 1 : 0

  bucket = aws_s3_bucket.backups[0].id
  rule {
    id = "log"
    expiration {
      days = 30
    }
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "backups" {
  count = local.create_backups_bucket ? 1 : 0

  bucket = aws_s3_bucket.backups[0].id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
