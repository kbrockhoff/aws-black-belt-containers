data "aws_iam_policy_document" "log_storage" {
  statement {
    sid    = "AWSELBConfigure"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::127311923021:root"]
    }
    actions = [
      "s3:PutObject",
    ]
    resources = [
      "arn:aws:s3:::${local.logs_bucket_name}/*",
    ]
  }
  statement {
    sid    = "AWSLogDeliveryWrite"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["delivery.logs.amazonaws.com"]
    }
    actions = [
      "s3:PutObject",
    ]
    resources = [
      "arn:aws:s3:::${local.logs_bucket_name}/*",
    ]
    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values = [
        "bucket-owner-full-control",
      ]
    }
  }
  statement {
    sid    = "AWSLogDeliveryAclCheck"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["delivery.logs.amazonaws.com"]
    }
    actions = [
      "s3:GetBucketAcl",
    ]
    resources = [
      "arn:aws:s3:::${local.logs_bucket_name}",
    ]
  }
}

resource "aws_s3_bucket" "access_logs" {
  count = local.create_logs_bucket ? 1 : 0

  bucket        = local.logs_bucket_name
  force_destroy = true

  tags = merge(module.this.tags, {
    Name = local.logs_bucket_name
  })

  lifecycle {
    ignore_changes = [server_side_encryption_configuration]
  }
}

resource "aws_s3_bucket_policy" "access_logs" {
  count = local.create_logs_bucket ? 1 : 0

  bucket = aws_s3_bucket.access_logs[0].id
  policy = data.aws_iam_policy_document.log_storage.json
}

resource "aws_s3_bucket_acl" "access_logs" {
  count = local.create_logs_bucket ? 1 : 0

  bucket = aws_s3_bucket.access_logs[0].id
  acl    = "private"
}

resource "aws_s3_bucket_public_access_block" "access_logs" {
  count = local.create_logs_bucket ? 1 : 0

  bucket                  = aws_s3_bucket.access_logs[0].id
  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_lifecycle_configuration" "logs" {
  count = local.create_logs_bucket ? 1 : 0

  bucket = aws_s3_bucket.access_logs[0].id
  rule {
    id = "log"
    expiration {
      days = 30
    }
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "access_logs" {
  count = local.create_logs_bucket ? 1 : 0

  bucket = aws_s3_bucket.access_logs[0].id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
