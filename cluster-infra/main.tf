module "eks_blueprints" {
  source = "github.com/aws-ia/terraform-aws-eks-blueprints?ref=v4.1.0"

  create_eks                = true
  cluster_name              = local.cluster_name
  cluster_version           = var.eks_version
  vpc_id                    = data.aws_vpc.shared.id
  private_subnet_ids        = data.aws_subnets.node.ids
  cluster_ip_family         = "ipv4"
  cluster_service_ipv4_cidr = "172.20.0.0/16"

  cluster_kms_key_deletion_window_in_days = 14
  cluster_kms_key_additional_admin_arns = [
    data.aws_iam_role.administrator.arn,
    data.aws_iam_role.poweruser.arn,
  ]

  cluster_endpoint_public_access  = true
  cluster_endpoint_private_access = true

  create_cloudwatch_log_group            = true
  cluster_enabled_log_types              = var.cluster_enabled_log_types
  cloudwatch_log_group_retention_in_days = 14
  cloudwatch_log_group_kms_key_id        = module.logs_kms_key.key_arn

  managed_node_groups = {
    alwayson = {
      node_group_name = "alwayson"
      create_iam_role = false
      iam_role_arn    = aws_iam_role.managed_ng.arn
      # Node Group compute configuration
      instance_types = ["m6a.large"]
      subnet_ids     = data.aws_subnets.node.ids
      disk_size      = 100
      # Node Group scaling configuration
      desired_size = 2
      min_size     = 2
      max_size     = 2
      update_config = [{
        max_unavailable_percentage = 50
      }]
      public_ip         = false
      enable_monitoring = true
      eni_delete        = true
    },
    exspot = {
      node_group_name = "exspot"
      create_iam_role = false
      iam_role_arn    = aws_iam_role.managed_ng.arn
      # Node Group compute configuration
      ami_type             = "AL2_x86_64"
      release_version      = ""
      capacity_type        = "SPOT"
      instance_types       = ["m5.large", "m4.large", "m6a.large", "m5a.large", "m5d.large"]
      subnet_ids           = data.aws_subnets.node.ids
      force_update_version = true
      # Node Group scaling configuration
      desired_size = 1
      max_size     = 4
      min_size     = 0
      # Launch template configuration
      create_launch_template = true
      launch_template_os     = "amazonlinux2eks"
      pre_userdata           = templatefile("${path.module}/templates/eks-nodes-userdata.sh", {})
      k8s_taints             = [{ key = "spotInstance", value = "true", effect = "NO_SCHEDULE" }]
      k8s_labels = {
        dbs-deployer = "Terraform"
      }
      public_ip         = false
      enable_monitoring = true
      eni_delete        = true
      # Root storage
      block_device_mappings = [
        {
          device_name           = "/dev/xvda"
          volume_type           = "gp2"
          volume_size           = 100
          delete_on_termination = true
          encrypted             = false
          #          kms_key_id            = module.ebs_kms_key.key_arn
        }
      ]
    }
  }

  map_accounts = local.eks_map_accounts
  map_roles    = local.eks_map_roles
  map_users    = local.eks_map_users

  tags = module.this.tags
}

module "eks_blueprints_base_addons" {
  source = "github.com/aws-ia/terraform-aws-eks-blueprints//modules/kubernetes-addons?ref=v4.1.0"

  eks_cluster_id               = module.eks_blueprints.eks_cluster_id
  eks_worker_security_group_id = module.eks_blueprints.worker_node_security_group_id
  auto_scaling_group_names     = module.eks_blueprints.self_managed_node_group_autoscaling_groups

  enable_amazon_eks_vpc_cni = true
  amazon_eks_vpc_cni_config = {
    addon_version     = data.aws_eks_addon_version.latest["vpc-cni"].version
    resolve_conflicts = "OVERWRITE"
  }

  enable_amazon_eks_coredns = true
  amazon_eks_coredns_config = {
    addon_version     = data.aws_eks_addon_version.latest["coredns"].version
    resolve_conflicts = "OVERWRITE"
  }
  enable_amazon_eks_kube_proxy = true
  amazon_eks_kube_proxy_config = {
    addon_version     = data.aws_eks_addon_version.default["kube-proxy"].version
    resolve_conflicts = "OVERWRITE"
  }
  enable_amazon_eks_aws_ebs_csi_driver = true

  tags = module.this.tags

  depends_on = [module.eks_blueprints]
}

module "vpc_cni" {
  source = "./vpc-cni"

  enabled                   = false
  cluster_name              = module.eks_blueprints.eks_cluster_id
  vpc_id                    = data.aws_vpc.shared.id
  vpccni_version            = data.aws_eks_addon_version.latest["vpc-cni"].version
  pod_subnets               = data.aws_subnets.pod.ids
  enable_custom_network     = true
  pod_security_group_id     = module.eks_blueprints.worker_node_security_group_id
  cluster_security_group_id = module.eks_blueprints.cluster_security_group_id
  cluster_oidc_issuer_url   = module.eks_blueprints.eks_oidc_issuer_url
  oidc_provider_arn         = module.eks_blueprints.eks_oidc_provider_arn

  tags = module.this.tags

  depends_on = [module.eks_blueprints_base_addons]
}
