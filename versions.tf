terraform {
  cloud {
    organization = "nbb-org"

    workspaces {
      name = "learn-terraform"
    }
  }
  required_providers {
    aws = {
      source = "hashicorp/aws"
      # version = "3.59.0"
    }
  }
}