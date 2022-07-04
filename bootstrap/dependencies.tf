data "aws_partition" "current" {}

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "external" "pwgen" {
  program = ["${path.module}/gen-passwd.sh"]
}