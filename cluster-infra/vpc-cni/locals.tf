locals {
  vpccnirole_name      = "${var.cluster_name}-aws-node-irsa"
  customnetwork_status = data.external.cni_cfg[0].result["customnetwork"]
}
