data "aws_iam_policy_document" "managed_ng_assume_role_policy" {
  statement {
    sid = "EKSWorkerAssumeRole"
    principals {
      type        = "Service"
      identifiers = ["ec2.${local.partition_suffix}"]
    }
    actions = [
      "sts:AssumeRole",
    ]
  }
}

resource "aws_iam_role" "managed_ng" {
  name                  = local.noderole_name
  description           = "EKS Managed Node group IAM Role"
  assume_role_policy    = data.aws_iam_policy_document.managed_ng_assume_role_policy.json
  force_detach_policies = true
  managed_policy_arns = [
    "arn:${local.partition_id}:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:${local.partition_id}:iam::aws:policy/AmazonEKS_CNI_Policy",
    "arn:${local.partition_id}:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
    "arn:${local.partition_id}:iam::aws:policy/AmazonSSMManagedInstanceCore"
  ]

  tags = merge(module.this.tags, {
    Name = local.noderole_name
  })
}

resource "aws_iam_instance_profile" "karpenter" {
  name = local.karp_profile_name
  role = aws_iam_role.managed_ng.name

  tags = merge(module.this.tags, {
    Name = local.karp_profile_name
  })
}
