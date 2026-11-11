terraform {
  required_version = ">= 1.10"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

  # Bucket is created by infra/bootstrap. use_lockfile = S3-native locking
  # (no DynamoDB table needed).
  backend "s3" {
    bucket       = "kosisochukwuakaeze-com-tfstate"
    key          = "site/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}

# Everything in us-east-1: CloudFront only accepts ACM certificates from
# that region, and the bucket's region doesn't matter behind a CDN.
provider "aws" {
  region = "us-east-1"

  default_tags {
    tags = {
      Project   = "portfolio-website"
      ManagedBy = "terraform"
      Stack     = "site"
    }
  }
}
