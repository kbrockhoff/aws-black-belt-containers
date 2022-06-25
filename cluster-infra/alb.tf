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

resource "aws_lb_target_group" "https" {
  name        = "${local.lb_name}-https"
  port        = 443
  protocol    = "HTTPS"
  target_type = "ip"
  vpc_id      = data.aws_vpc.shared.id

  tags = merge(module.this.tags, {
    Name = "${local.lb_name}-https"
  })
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.eksingress.arn
  port              = "443"
  protocol          = "HTTPS"
  certificate_arn   = local.acm_certificate_arn
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.https.arn
  }

  tags = merge(module.this.tags, {
    Name = "${local.lb_name}-https"
  })

  depends_on = [aws_acm_certificate_validation.ingress]
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.eksingress.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }

  tags = merge(module.this.tags, {
    Name = "${local.lb_name}-http"
  })

  depends_on = [aws_acm_certificate_validation.ingress]
}
