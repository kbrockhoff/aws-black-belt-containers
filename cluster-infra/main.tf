module "eks_blueprints" {
  source = "github.com/aws-ia/terraform-aws-eks-blueprints?ref=v4.2.1"

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
  cloudwatch_log_group_retention_in_days = var.log_retention_days
  cloudwatch_log_group_kms_key_id        = module.logs_kms_key.key_arn

  managed_node_groups = {
    alwayson = {
      node_group_name = "alwayson"
      create_iam_role = false
      iam_role_arn    = aws_iam_role.managed_ng.arn
      # Node Group compute configuration
      instance_types = ["m6a.large"]
      subnet_ids     = data.aws_subnets.node.ids
      # Node Group scaling configuration
      desired_size      = 3
      min_size          = 3
      max_size          = 3
      max_unavailable   = 1
      public_ip         = false
      enable_monitoring = true
      eni_delete        = true
      # Launch template configuration
      create_launch_template = true
      launch_template_os     = "amazonlinux2eks"
      pre_userdata           = templatefile("${path.module}/templates/eks-nodes-userdata.sh", {})
      k8s_taints             = []
      k8s_labels = {
        dbs-deployer = "Terraform"
      }
      # Root storage
      block_device_mappings = [
        {
          device_name           = "/dev/xvda"
          volume_type           = "gp3"
          volume_size           = 100
          iops                  = 3000
          throughput            = 125
          delete_on_termination = true
          encrypted             = false
        }
      ]
    }
  }

  map_accounts = local.eks_map_accounts
  map_roles    = local.eks_map_roles
  map_users    = local.eks_map_users

  tags = module.this.tags
}

module "vpc_cni" {
  source = "./vpc-cni"

  enabled                   = true
  region                    = var.region
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

  depends_on = [module.eks_blueprints]
}

module "ebs_csi" {
  source = "./ebs-csi"

  enabled        = true
  cluster_name   = module.eks_blueprints.eks_cluster_id
  ebs_kms_key_id = module.ebs_kms_key.key_arn

  tags = module.this.tags

  depends_on = [module.vpc_cni]
}

module "eks_blueprints_base_addons" {
  source = "github.com/aws-ia/terraform-aws-eks-blueprints//modules/kubernetes-addons?ref=v4.2.1"

  eks_cluster_id               = module.eks_blueprints.eks_cluster_id
  eks_worker_security_group_id = module.eks_blueprints.worker_node_security_group_id
  auto_scaling_group_names     = module.eks_blueprints.self_managed_node_group_autoscaling_groups

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
  amazon_eks_aws_ebs_csi_driver_config = {
    addon_version     = data.aws_eks_addon_version.latest["aws-ebs-csi-driver"].version
    resolve_conflicts = "OVERWRITE"
  }

  enable_metrics_server                    = true
  metrics_server_helm_config               = {}

  enable_aws_for_fluentbit = true
  aws_for_fluentbit_helm_config = {
    namespace                                 = "logging"
    aws_for_fluent_bit_cw_log_group           = local.loggroup_name
    aws_for_fluentbit_cwlog_retention_in_days = var.log_retention_days
    create_namespace                          = true
    values = [templatefile("${path.module}/templates/aws-for-fluentbit-values.yaml", {
      aws_region                          = var.region
      log_group_name = local.loggroup_name
      service_account_name = "${local.cluster_name}-aws-for-fluent-bit-irsa"
    })]
    set = [
      {
        name  = "nodeSelector.kubernetes\\.io/os"
        value = "linux"
      }
    ]
  }
  aws_for_fluentbit_irsa_policies = []
  aws_for_fluentbit_cw_log_group_name = local.loggroup_name
  aws_for_fluentbit_cw_log_group_retention = var.log_retention_days
  aws_for_fluentbit_cw_log_group_kms_key_arn = module.logs_kms_key.key_arn

  enable_aws_load_balancer_controller      = true
  aws_load_balancer_controller_helm_config = {}

  enable_cert_manager = true
  cert_manager_helm_config = {}
  cert_manager_irsa_policies = []
  cert_manager_install_letsencrypt_issuers = false

  tags = module.this.tags

  depends_on = [module.vpc_cni]
}
