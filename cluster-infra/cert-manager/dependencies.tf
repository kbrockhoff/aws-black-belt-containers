data "aws_partition" "current" {}

data "aws_route53_zone" "public" {
  count = var.enabled ? 1 : 0

  name         = var.route53_hosted_zone_name
  private_zone = false
}
