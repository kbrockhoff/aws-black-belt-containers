resource "aws_acm_certificate" "ingress" {
  count = var.create_acm_certificate ? 1 : 0

  domain_name               = local.acm_name
  validation_method         = "DNS"
  subject_alternative_names = local.acm_alternatives
  tags = merge(module.this.tags, {
    Name = local.dns_name
  })

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "cert_validate" {
  for_each = {
    for dvo in local.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = local.zone_id
}

resource "aws_acm_certificate_validation" "ingress" {
  count = var.create_acm_certificate ? 1 : 0

  certificate_arn         = aws_acm_certificate.ingress[0].arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validate : record.fqdn]
}
