resource "aws_route53_record" "ipv4" {
  for_each = toset(var.ingress_hostnames)

  name    = each.value
  type    = "A"
  zone_id = var.route53_zone_id
  alias {
    evaluate_target_health = false
    name                   = var.alb_dns_name
    zone_id                = var.alb_zone_id
  }
}

resource "aws_route53_record" "ipv6" {
  for_each = toset(var.ingress_hostnames)

  name    = each.value
  type    = "AAAA"
  zone_id = var.route53_zone_id
  alias {
    evaluate_target_health = false
    name                   = var.alb_dns_name
    zone_id                = var.alb_zone_id
  }
}
