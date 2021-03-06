module "karpenter_launch_template" {
  source = "github.com/aws-ia/terraform-aws-eks-blueprints//modules/launch-templates?ref=v4.2.1"

  eks_cluster_id = var.addon_context.eks_cluster_id

  launch_template_config = {
    linux = {
      ami                    = data.aws_ami.eks.id
      launch_template_prefix = local.node_group_name_prefix
      iam_instance_profile   = var.worker_node_iam_instance_profile
      vpc_security_group_ids = [var.worker_node_security_group_id]
      block_device_mappings = [
        {
          device_name           = "/dev/xvda"
          volume_type           = "gp3"
          volume_size           = 100
          iops                  = 3000
          throughput            = 125
          delete_on_termination = true
          encrypted             = true
        }
      ]
      pre_userdata            = var.launch_template_pre_userdata
      bootstrap_extra_args    = var.launch_template_bootstrap_extra_args
      post_userdata           = var.launch_template_post_userdata
      kubelet_extra_args      = var.launch_template_kubelet_extra_args
      service_ipv4_cidr       = var.launch_template_service_ipv4_cidr
      enable_metadata_options = true
    }
  }

  tags = merge(var.addon_context.tags, {
    Name = local.node_group_name_prefix
  })
}

resource "kubectl_manifest" "karpenter_default" {
  yaml_body = <<YAML
apiVersion: karpenter.sh/v1alpha5
kind: Provisioner
metadata:
  name: ${var.karpenter_provisioner_name}
spec:
  ttlSecondsUntilExpired: 2592000
  ttlSecondsAfterEmpty: 600
  labels:
    daughertylabs.io/networktags: private
    daughertylabs.io/availability: preemptable
  requirements:
    - key: "topology.kubernetes.io/zone"
      operator: In
      values: ${local.azs_string}
    - key: "kubernetes.io/arch"
      operator: In
      values: ["arm64", "amd64"]
    - key: "karpenter.sh/capacity-type"
      operator: In
      values: ["spot", "on-demand"]
  limits:
    resources:
      cpu: 1000
      memory: 1000Gi
  provider:
    launchTemplate: '${module.karpenter_launch_template.launch_template_name["linux"]}'
    subnetSelector:
      dbs-networktags: private
  ttlSecondsAfterEmpty: 120
YAML
}
