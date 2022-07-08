module "eks_blueprints" {
  source = "github.com/aws-ia/terraform-aws-eks-blueprints?ref=v4.2.1"

  create_eks                = true
  cluster_name              = local.cluster_name
  cluster_version           = var.eks_version
  vpc_id                    = data.aws_vpc.shared.id
  private_subnet_ids        = data.aws_subnets.node.ids
  cluster_ip_family         = "ipv4"
  cluster_service_ipv4_cidr = "172.20.0.0/16"
  node_security_group_additional_rules = {
    # Extend node-to-node security group rules. Recommended and required for the Add-ons
    ingress_self_all = {
      description = "Node to node all ports/protocols"
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      type        = "ingress"
      cidr_blocks = local.all_cidrs
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
  node_security_group_tags = {
    "karpenter.sh/discovery/${local.cluster_name}" = local.cluster_name
  }

  cluster_kms_key_deletion_window_in_days = 14
  cluster_kms_key_additional_admin_arns = [
    data.aws_iam_role.administrator.arn,
    data.aws_iam_role.poweruser.arn,
    data.aws_iam_role.github.arn,
  ]

  cluster_endpoint_public_access  = true
  cluster_endpoint_private_access = true

  create_cloudwatch_log_group            = true
  cluster_enabled_log_types              = var.cluster_enabled_log_types
  cloudwatch_log_group_retention_in_days = var.log_retention_days
  cloudwatch_log_group_kms_key_id        = aws_kms_key.logs.arn

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
  ebs_kms_key_id = aws_kms_key.ebs.arn

  tags = module.this.tags

  depends_on = [module.vpc_cni]
}

module "eks_blueprints_base_addons" {
  source = "github.com/aws-ia/terraform-aws-eks-blueprints//modules/kubernetes-addons?ref=v4.2.1"

  eks_cluster_id               = module.eks_blueprints.eks_cluster_id
  eks_cluster_domain           = data.aws_route53_zone.public.name
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

  enable_metrics_server      = true
  metrics_server_helm_config = {}

  enable_aws_node_termination_handler = true
  enable_karpenter                    = true

  enable_aws_for_fluentbit = true
  aws_for_fluentbit_helm_config = {
    namespace                                 = "logging"
    aws_for_fluent_bit_cw_log_group           = local.appslog_name
    aws_for_fluentbit_cwlog_retention_in_days = var.log_retention_days
    create_namespace                          = true
    values = [templatefile("${path.module}/templates/aws-for-fluentbit-values.yaml", {
      aws_region           = var.region
      log_group_name       = local.appslog_name
      service_account_name = "${local.cluster_name}-aws-for-fluent-bit-irsa"
      cluster_name         = local.cluster_name
      dataplane_log_group  = aws_cloudwatch_log_group.dataplane.name
      host_log_group       = aws_cloudwatch_log_group.host.name
    })]
    set = [
      {
        name  = "nodeSelector.kubernetes\\.io/os"
        value = "linux"
      }
    ]
  }
  aws_for_fluentbit_irsa_policies = [
    "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy",
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
  ]
  aws_for_fluentbit_cw_log_group_name        = local.appslog_name
  aws_for_fluentbit_cw_log_group_retention   = var.log_retention_days
  aws_for_fluentbit_cw_log_group_kms_key_arn = null #aws_kms_key.logs.arn # needs bugfix in blueprints

  enable_opentelemetry_operator      = true
  opentelemetry_operator_helm_config = {}
  enable_amazon_eks_adot             = false
  amazon_eks_adot_config             = {}

  enable_cert_manager = false # installed by otel
  cert_manager_helm_config = {
    version = "v1.8.2"
    values  = [templatefile("${path.module}/templates/cert-manager-values.yaml", {})]
  }
  cert_manager_irsa_policies = []
  cert_manager_domain_names = [
    data.aws_route53_zone.public.name,
  ]
  cert_manager_install_letsencrypt_issuers = false
  cert_manager_letsencrypt_email           = ""

  enable_aws_load_balancer_controller      = true
  aws_load_balancer_controller_helm_config = {}

  enable_ingress_nginx = true
  ingress_nginx_helm_config = {
    values = [templatefile("${path.module}/templates/ingress-nginx-values.yaml", {})]
  }

  enable_argocd = true
  argocd_helm_config = {
    values = [templatefile("${path.module}/templates/argocd-values.yaml", {})]
  }
  argocd_applications               = {}
  argocd_admin_password_secret_name = ""

  tags = module.this.tags

  depends_on = [module.eks_blueprints, module.vpc_cni, aws_kms_key.logs]
}

resource "kubectl_manifest" "default_tg" {
  yaml_body = <<YAML
apiVersion: elbv2.k8s.aws/v1beta1
kind: TargetGroupBinding
metadata:
  name: ingress-nginx
  namespace: ingress-nginx
spec:
  targetGroupARN: ${aws_lb_target_group.https.arn}
  targetType: ip
  serviceRef:
    name: ingress-nginx-controller
    port: 443
YAML

  depends_on = [module.eks_blueprints_base_addons]
}

module "argocd_ingress" {
  source = "./argocd-ingress"

  ingress_hostnames = [
    "gitops.${local.dns_name}",
  ]
  route53_zone_id = data.aws_route53_zone.public.zone_id
  alb_dns_name    = aws_lb.eksingress.dns_name
  alb_zone_id     = aws_lb.eksingress.zone_id

  depends_on = [kubectl_manifest.default_tg]
}

module "gloo_edge" {
  source = "./gloo-edge"

  helm_config = {
    values = [templatefile("${path.module}/templates/glooedge-values.yaml", {})]
  }
  addon_context = {
    aws_caller_identity_account_id = local.account_id
    aws_caller_identity_arn        = data.aws_caller_identity.current.arn
    aws_eks_cluster_endpoint       = module.eks_blueprints.eks_cluster_endpoint
    aws_partition_id               = local.partition_id
    aws_region_name                = var.region
    eks_cluster_id                 = module.eks_blueprints.eks_cluster_id
    eks_oidc_issuer_url            = module.eks_blueprints.eks_oidc_issuer_url
    eks_oidc_provider_arn          = module.eks_blueprints.eks_oidc_provider_arn
    tags                           = module.this.tags
  }
  create_target_group    = true
  vpc_id                 = data.aws_vpc.shared.id
  alb_https_listener_arn = aws_lb_listener.https.arn
  routed_host_names = [
    "api.${local.dns_name}",
    "*.api.${local.dns_name}",
  ]

  depends_on = [module.eks_blueprints_base_addons]
}

module "prometheus_stack" {
  source = "./prometheus"

  helm_config = {
    values = [templatefile("${path.module}/templates/kube-prom-stack-values.yaml", {
      alertmanager_hosts = local.alertmanager_hosts
      grafana_hosts      = local.grafana_hosts
    })]
  }
  addon_context = {
    aws_caller_identity_account_id = local.account_id
    aws_caller_identity_arn        = data.aws_caller_identity.current.arn
    aws_eks_cluster_endpoint       = module.eks_blueprints.eks_cluster_endpoint
    aws_partition_id               = local.partition_id
    aws_region_name                = var.region
    eks_cluster_id                 = module.eks_blueprints.eks_cluster_id
    eks_oidc_issuer_url            = module.eks_blueprints.eks_oidc_issuer_url
    eks_oidc_provider_arn          = module.eks_blueprints.eks_oidc_provider_arn
    tags                           = module.this.tags
  }
  ingress_hostnames = concat(local.alertmanager_hosts, local.grafana_hosts)
  route53_zone_id   = data.aws_route53_zone.public.zone_id
  alb_dns_name      = aws_lb.eksingress.dns_name
  alb_zone_id       = aws_lb.eksingress.zone_id

  depends_on = [module.eks_blueprints_base_addons]
}

module "karpenter_provisioning" {
  source = "./karpenter-provision"

  addon_context = {
    aws_caller_identity_account_id = local.account_id
    aws_caller_identity_arn        = data.aws_caller_identity.current.arn
    aws_eks_cluster_endpoint       = module.eks_blueprints.eks_cluster_endpoint
    aws_partition_id               = local.partition_id
    aws_region_name                = var.region
    eks_cluster_id                 = module.eks_blueprints.eks_cluster_id
    eks_oidc_issuer_url            = module.eks_blueprints.eks_oidc_issuer_url
    eks_oidc_provider_arn          = module.eks_blueprints.eks_oidc_provider_arn
    tags                           = module.this.tags
  }
  karpenter_provisioner_name       = "default"
  eks_cluster_version              = module.eks_blueprints.eks_cluster_version
  worker_node_security_group_id    = module.eks_blueprints.worker_node_security_group_id
  worker_node_iam_instance_profile = module.eks_blueprints.managed_node_group_iam_instance_profile_id[0]
  launch_template_pre_userdata     = templatefile("${path.module}/templates/eks-nodes-userdata.sh", {})

  depends_on = [module.eks_blueprints_base_addons]
}
