terraform {
  cloud {
    organization = "virtualizacao"
    workspaces {
      tags = ["exemplo-terraform-aws"]
    }
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}