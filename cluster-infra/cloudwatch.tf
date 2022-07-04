resource "aws_cloudwatch_log_group" "applications" {
  name              = local.appslog_name
  retention_in_days = var.log_retention_days
  kms_key_id        = aws_kms_key.logs.arn

  tags = merge(module.this.tags, {
    Name = local.appslog_name
  })
}

resource "aws_cloudwatch_log_group" "dataplane" {
  name              = local.datalog_name
  retention_in_days = var.log_retention_days
  kms_key_id        = aws_kms_key.logs.arn

  tags = merge(module.this.tags, {
    Name = local.datalog_name
  })
}

resource "aws_cloudwatch_log_group" "host" {
  name              = local.hostlog_name
  retention_in_days = var.log_retention_days
  kms_key_id        = aws_kms_key.logs.arn

  tags = merge(module.this.tags, {
    Name = local.hostlog_name
  })
}
