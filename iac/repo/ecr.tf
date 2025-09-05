terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "=6.10.0"
    }
  }
}

provider "aws" {
    region = var.aws_region
}

resource "aws_ecrpublic_repository" "ecr_repo" {
  repository_name = var.aws_ecr_repo_name
}