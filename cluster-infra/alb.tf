resource "aws_lb" "eksingress" {
  name               = local.lb_name
  load_balancer_type = "application"
  internal           = false
  dynamic "access_logs" {
    for_each = toset(var.enable_access_logs ? [local.lb_name] : [])
    content {
      enabled = var.enable_access_logs
      bucket  = local.logs_bucket_name
      prefix  = access_logs.value
    }
  }
  enable_cross_zone_load_balancing = true
  ip_address_type                  = "dualstack"
  subnets                          = data.aws_subnets.lb.ids

  tags = merge(module.this.tags, {
    Name = local.lb_name
  })

  depends_on = [aws_s3_bucket.access_logs]
}

resource "aws_lb_target_group" "eksingress" {
  name              = "${local.lb_name}-tg"
  port              = 443
  protocol          = "TLS"
  target_type       = "ip"
  vpc_id            = data.aws_vpc.shared.id
  proxy_protocol_v2 = true

  tags = merge(module.this.tags, {
    Name = "${local.lb_name}-tg"
  })
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.eksingress.arn
  port              = "443"
  protocol          = "TLS"
  certificate_arn   = local.acm_certificate_arn
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  alpn_policy       = "HTTP2Preferred"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.eksingress.arn
  }

  tags = merge(module.this.tags, {
    Name = "${local.lb_name}-https"
  })

  depends_on = [aws_acm_certificate_validation.ingress]
}
