data "aws_region" "current" {}

data "aws_acmpca_certificate_authority" "shared" {
  count = var.enabled ? 1 : 0

  arn = var.awspca_privateca_arn
}
