variable "region" {
  description = "AWS region for the state bucket. us-east-1 keeps everything next to the ACM certificate CloudFront needs."
  type        = string
  default     = "us-east-1"
}

variable "domain_name" {
  description = "Apex domain, e.g. example.com"
  type        = string
}

variable "github_repo" {
  description = "GitHub repository allowed to assume the CI roles, as owner/name"
  type        = string

  validation {
    condition     = length(split("/", var.github_repo)) == 2
    error_message = "github_repo must be in the form owner/name."
  }
}

variable "github_owner_id" {
  description = "Numeric GitHub ID of the repo owner (\"owner.id\" from https://api.github.com/repos/OWNER/NAME)"
  type        = string
}

variable "github_repo_id" {
  description = "Numeric GitHub ID of the repo (\"id\" from https://api.github.com/repos/OWNER/NAME)"
  type        = string
}

variable "state_bucket_name" {
  description = "Globally unique S3 bucket name for Terraform remote state"
  type        = string
}

variable "site_bucket_name" {
  description = "Globally unique S3 bucket name the site stack will create (the deploy role is scoped to it)"
  type        = string
}

variable "create_github_oidc_provider" {
  description = "Set to false if this AWS account already has the token.actions.githubusercontent.com OIDC provider"
  type        = bool
  default     = true
}
