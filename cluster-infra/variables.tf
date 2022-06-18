variable "profile" {
  description = "AWS CLI profile to use"
  type        = string
}

variable "region" {
  description = "Default infrastructure region"
  type        = string
  default     = "us-west-2"
}

variable "eks_version" {
  description = "Version of the EKS K8S cluster"
  type        = string
  default     = "1.22"
}

variable "cluster_enabled_log_types" {
  description = "A list of the desired control plane logging to enable."
  type        = list(string)
  default     = ["api", "controllerManager", "scheduler", "audit", "authenticator"]
}

variable "eks_map_roles" {
  description = "Additional IAM roles to add to the aws-auth configmap."
  type = list(object({
    rolearn  = string
    username = string
    groups   = list(string)
  }))
  default = []
}

variable "eks_write_kubeconfig" {
  description = "Flag for eks module to write kubeconfig"
  default     = false
}

# ECR
variable "ecr_repos" {
  description = "List of docker repositories"
  type        = list(any)
  default     = ["demo"]
}

variable "ecr_repo_retention_count" {
  description = "number of images to store in ECR"
  default     = 32
}

variable "kubeproxy_version" {
  description = "kube-proxy addon version to use."
  type        = string
  default     = "v1.22.6-eksbuild.1"
}

variable "coredns_version" {
  description = "coredns addon version to use."
  type        = string
  default     = "v1.8.7-eksbuild.1"
}
