resource "aws_cloudwatch_log_group" "dataplane" {
  name              = "/aws/containerinsights/${local.cluster_name}/dataplane"
  retention_in_days = var.log_retention_days
  kms_key_id        = module.logs_kms_key.key_arn

  tags = merge(module.this.tags, {
    Name = "/aws/containerinsights/${local.cluster_name}/dataplane"
  })
}

resource "aws_cloudwatch_log_group" "host" {
  name              = "/aws/containerinsights/${local.cluster_name}/host"
  retention_in_days = var.log_retention_days
  kms_key_id        = module.logs_kms_key.key_arn

  tags = merge(module.this.tags, {
    Name = "/aws/containerinsights/${local.cluster_name}/host"
  })
}
