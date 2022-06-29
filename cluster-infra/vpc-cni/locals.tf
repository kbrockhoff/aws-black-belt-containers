locals {
  cni_patch_needed = var.enabled && var.enable_custom_network ? (
    data.external.cni_cfg[0].result["customnetwork"] == "false"
  ) : false
}
