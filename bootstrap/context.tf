module "this" {
  source = "git::https://github.com/daughertylabs/terraform-local-context.git?ref=v1.0.1"

  enabled         = true
  organization    = "dl"
  cloud_provider  = "aws"
  namespace       = "k8strng"
  name            = "kbgithub"
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
