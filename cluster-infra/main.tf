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

  node_security_group_additional_rules = {
    # Extend node-to-node security group rules. Recommended and required for the Add-ons
    ingress_self_all = {
      description = "Node to node all ports/protocols"
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      type        = "ingress"
      self        = true
    }
    # Recommended outbound traffic for Node groups
    egress_all = {
      description      = "Node all egress"
      protocol         = "-1"
      from_port        = 0
      to_port          = 0
      type             = "egress"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }
    # Allows Control Plane Nodes to talk to Worker nodes on all ports. Added this to simplify the example and further avoid issues with Add-ons communication with Control plane.
    # This can be restricted further to specific port based on the requirement for each Add-on e.g., metrics-server 4443, spark-operator 8080, karpenter 8443 etc.
    # Change this according to your security requirements if needed
    ingress_cluster_to_node_all_traffic = {
      description                   = "Cluster API to Nodegroup all traffic"
      protocol                      = "-1"
      from_port                     = 0
      to_port                       = 0
      type                          = "ingress"
      source_cluster_security_group = true
    }
  }

  managed_node_groups = {
    alwayson = {
      node_group_name = "always-on"
      # Node Group compute configuration
      ami_type             = "AL2_x86_64"
      release_version      = ""
      capacity_type        = "ON_DEMAND"
      instance_types       = ["m6a.large"]
      subnet_ids           = data.aws_subnets.node.ids
      force_update_version = true
      # Node Group scaling configuration
      desired_size    = 3
      max_size        = 3
      min_size        = 3
      max_unavailable = 1
      # Launch template configuration
      create_launch_template = true
      launch_template_os     = "amazonlinux2eks"
      kubelet_extra_args     = "--node-labels=noderole=infrastructure --max-pods=29"
      bootstrap_extra_args   = "--container-runtime containerd"
      k8s_taints             = []
      k8s_labels = {
        Environment = "preprod"
        Zone        = "dev"
        Runtime     = "containerd"
      }
      public_ip         = false
      enable_monitoring = true
      eni_delete        = true
      # Root storage
      block_device_mappings = [
        {
          device_name           = "/dev/xvda"
          volume_type           = "gp3"
          volume_size           = 100
          delete_on_termination = true
          encrypted             = true
          kms_key_id            = module.ebs_kms_key.key_arn
          iops                  = 3000
          throughput            = 125
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

  enabled                   = true
  cluster_name              = module.eks_blueprints.eks_cluster_id
  vpc_id                    = data.aws_vpc.shared.id
  vpccni_version            = data.aws_eks_addon_version.latest["vpc-cni"].version
  pod_subnets               = data.aws_subnets.pod.ids
  enable_custom_network     = true
  pod_create_security_group = true
  cluster_security_group_id = module.eks_blueprints.cluster_security_group_id
  cluster_oidc_issuer_url   = module.eks_blueprints.eks_oidc_issuer_url
  oidc_provider_arn         = module.eks_blueprints.eks_oidc_provider_arn

  tags = module.this.tags

  depends_on = [module.eks_blueprints_base_addons]
}
