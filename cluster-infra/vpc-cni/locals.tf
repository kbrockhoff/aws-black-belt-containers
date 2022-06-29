locals {
  customnetwork_status = data.external.cni_cfg[0].result["customnetwork"]
}
