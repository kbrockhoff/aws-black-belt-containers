module "this" {
  source = "git::https://github.com/daughertylabs/terraform-local-context.git?ref=v1.0.1"

  enabled         = true
  organization    = "dl"
  cloud_provider  = "aws"
  namespace       = "k8strng"
  name            = "bbckb"
  environment     = "sandbox"
  env_subtype     = ""
  project_owners  = ["kevin.brockhoff@daugherty.com"]
  project         = "Black Belts"
  project_type    = "NONBILL"
  code_owners     = ["kevin.brockhoff@daugherty.com"]
  data_owners     = ["kevin.brockhoff@daugherty.com"]
  availability    = "preemptable"
  deployer        = "Terraform"
  confidentiality = "confidential"
  deletion_date   = "2022-08-05T18:00:00Z"
}
