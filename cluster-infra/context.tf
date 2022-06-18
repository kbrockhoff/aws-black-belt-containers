module "this" {
  source = "git::git@bitbucket.org:DBSDEVMAN/terraform-local-dbscontext.git?ref=v0.3.0"

  enabled         = true
  organization    = "dl"
  cloud_provider  = "aws"
  namespace       = "k8strng"
  name            = "bbckb"
  environment     = "sandbox"
  env_subtype     = ""
  project_owners  = ["kevin.brockhoff@daugherty.com"]
  project         = "N/A"
  project_type    = "N/A"
  code_owners     = ["kevin.brockhoff@daugherty.com"]
  data_owners     = ["kevin.brockhoff@daugherty.com"]
  availability    = "preemptable"
  deployer        = "Terraform"
  confidentiality = "confidential"
}
