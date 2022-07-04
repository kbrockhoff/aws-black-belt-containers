terraform {
  required_version = "1.2.3"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.19.0"
    }
    external = {
      source  = "hashicorp/external"
      version = "2.2.2"
    }
  }
}

provider "aws" {
  region = "us-west-2"
}
