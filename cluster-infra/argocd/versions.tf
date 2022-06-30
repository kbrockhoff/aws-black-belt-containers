terraform {
  required_version = ">= 1.0.0, < 2.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 5.0.0"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.7.0, < 2.0.0"
    }
    null = {
      source  = "hashicorp/null"
      version = ">= 3.0.0, < 4.0.0"
    }
    local = {
      source  = "hashicorp/local"
      version = ">= 2.0.0, < 3.0.0"
    }
    external = {
      source  = "hashicorp/external"
      version = ">= 2.0.0, < 3.0.0"
    }
  }
}
