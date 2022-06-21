resource "aws_route53_record" "public" {
  name    = local.dns_name
  type    = "A"
  zone_id = data.aws_route53_zone.public.zone_id
  alias {
    name                   = aws_lb.eksingress.dns_name
    zone_id                = aws_lb.eksingress.zone_id
    evaluate_target_health = false
  }
}
