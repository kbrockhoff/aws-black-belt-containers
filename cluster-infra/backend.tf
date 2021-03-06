terraform {
  required_version = "1.2.3"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.19.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.11.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "2.6.0"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "1.14.0"
    }
    http = {
      source  = "terraform-aws-modules/http"
      version = "2.4.1"
    }
    local = {
      source  = "hashicorp/local"
      version = "2.2.3"
    }
    null = {
      source  = "hashicorp/null"
      version = "3.1.1"
    }
    cloudinit = {
      source  = "hashicorp/cloudinit"
      version = "2.2.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "3.4.0"
    }
    time = {
      source  = "hashicorp/time"
      version = "0.7.2"
    }
    external = {
      source  = "hashicorp/external"
      version = "2.2.2"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.3.2"
    }
  }

  backend "s3" {}
}

provider "aws" {
  region = var.region
}

provider "aws" {
  alias  = "use2"
  region = "us-east-2"
}

provider "aws" {
  alias  = "use1"
  region = "us-east-1"
}

provider "kubernetes" {
  host                   = module.eks_blueprints.eks_cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks_blueprints.eks_cluster_certificate_authority_data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster-name", module.eks_blueprints.eks_cluster_id]
  }
}

provider "helm" {
  kubernetes {
    host                   = module.eks_blueprints.eks_cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks_blueprints.eks_cluster_certificate_authority_data)

    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args        = ["eks", "get-token", "--cluster-name", module.eks_blueprints.eks_cluster_id]
    }
  }
}

provider "kubectl" {
  apply_retry_count      = 10
  host                   = module.eks_blueprints.eks_cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks_blueprints.eks_cluster_certificate_authority_data)
  load_config_file       = false

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster-name", module.eks_blueprints.eks_cluster_id]
  }
}
