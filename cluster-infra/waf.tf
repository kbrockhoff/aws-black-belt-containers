resource "aws_wafv2_web_acl" "eksingress" {
  name        = local.waf_name
  description = "Protection of ${local.cluster_name} EKS ingress."
  scope       = "REGIONAL"
  default_action {
    allow {}
  }

  rule {
    name     = "awscommon"
    priority = 1
    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "${local.waf_name}-common"
      sampled_requests_enabled   = false
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = local.waf_name
    sampled_requests_enabled   = false
  }

  tags = merge(module.this.tags, {
    Name = local.waf_name
  })
}

resource "aws_wafv2_web_acl_association" "eksingress" {
  resource_arn = aws_lb.eksingress.arn
  web_acl_arn  = aws_wafv2_web_acl.eksingress.arn
}
