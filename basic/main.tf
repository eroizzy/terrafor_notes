terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "example" {
  ami           = "ami-04505e74c0741db8d" # Canonical, Ubuntu, 20.04 LTS, amd64 focal image build on 2021-11-29
  instance_type = "t2.micro"
}
