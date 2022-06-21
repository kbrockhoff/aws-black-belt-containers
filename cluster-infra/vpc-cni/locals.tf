locals {
  pod_security_group_id = var.pod_create_security_group ? (
    join("", aws_security_group.pods.*.id)
    ) : (
    var.pod_security_group_id
  )
  vpc_cidrs = concat(
    [for cba in data.aws_vpc.selected.cidr_block_associations : cba.cidr_block],
    [for knc in data.aws_eks_cluster.cluster.kubernetes_network_config : knc.service_ipv4_cidr],
  )
}
