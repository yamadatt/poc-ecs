provider "aws" {
  region = "ap-northeast-1"
  default_tags {
    tags = {
      resoruce = "terraform"
    }
  }
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}