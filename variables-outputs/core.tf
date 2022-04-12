terraform {
  backend "s3" {
    bucket         = "devops-directive-tf-state-eroizzy"
    key            = "var-out/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-state-locking"
    encrypt        = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = var.region
}

locals {
  extra_tag = "extra-tag"
}
