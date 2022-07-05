resource "aws_lb_target_group" "https" {
  count = var.create_target_group ? 1 : 0

  name        = "${var.addon_context.eks_cluster_id}-gloo"
  port        = 443
  protocol    = "HTTPS"
  target_type = "ip"
  vpc_id      = var.vpc_id

  tags = merge(var.addon_context.tags, {
    Name = "${var.addon_context.eks_cluster_id}-gloohttps"
  })
}

resource "aws_lb_listener_rule" "https" {
  count = var.create_target_group ? 1 : 0

  listener_arn = var.alb_https_listener_arn
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.https[0].arn
  }
  condition {
    host_header {
      values = var.routed_host_names
    }
  }
}

resource "kubectl_manifest" "api_tg" {
  count = var.create_target_group ? 1 : 0

  yaml_body = <<YAML
apiVersion: elbv2.k8s.aws/v1beta1
kind: TargetGroupBinding
metadata:
  name: gloo-gateway-proxy
  namespace: ${local.helm_config["namespace"]}
spec:
  targetGroupARN: ${aws_lb_target_group.https[0].arn}
  targetType: ip
  serviceRef:
    name: gateway-proxy
    port: 443
YAML

  depends_on = [module.helm_addon, aws_lb_target_group.https]
}
