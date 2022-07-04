locals {
  account_id       = data.aws_caller_identity.current.account_id
  partition_id     = data.aws_partition.current.id
  partition_suffix = data.aws_partition.current.dns_suffix
  region           = data.aws_region.current.name

  admin_secret_name    = "${module.this.name_prefix}-eksadmin"
  github_ssh_name      = "${module.this.name_prefix}-github"
  public_key_filename  = "~/.ssh/${module.this.name_prefix}.pub"
  private_key_filename = "~/.ssh/${module.this.name_prefix}"
}
