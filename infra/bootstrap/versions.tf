# One-time stack, applied from your laptop with admin credentials.
# State stays local (infra/bootstrap/terraform.tfstate, gitignored) because
# this stack creates the remote-state bucket everything else uses.
terraform {
  required_version = ">= 1.10"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = var.region

  default_tags {
    tags = {
      Project   = "portfolio-website"
      ManagedBy = "terraform"
      Stack     = "bootstrap"
    }
  }
}
