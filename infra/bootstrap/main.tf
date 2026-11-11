data "aws_caller_identity" "current" {}

# ---------------------------------------------------------------------------
# Remote state bucket (used by infra/site, with S3-native state locking)
# ---------------------------------------------------------------------------
resource "aws_s3_bucket" "tfstate" {
  bucket = var.state_bucket_name

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket_versioning" "tfstate" {
  bucket = aws_s3_bucket.tfstate.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "tfstate" {
  bucket = aws_s3_bucket.tfstate.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "tfstate" {
  bucket                  = aws_s3_bucket.tfstate.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "tfstate_tls_only" {
  bucket = aws_s3_bucket.tfstate.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid       = "DenyInsecureTransport"
      Effect    = "Deny"
      Principal = "*"
      Action    = "s3:*"
      Resource  = [aws_s3_bucket.tfstate.arn, "${aws_s3_bucket.tfstate.arn}/*"]
      Condition = { Bool = { "aws:SecureTransport" = "false" } }
    }]
  })
}

# ---------------------------------------------------------------------------
# DNS zone. Lives here (not in infra/site) so you can point your registrar's
# nameservers at it BEFORE the site stack tries to validate the certificate.
# ---------------------------------------------------------------------------
resource "aws_route53_zone" "site" {
  name = var.domain_name
}

# ---------------------------------------------------------------------------
# GitHub Actions -> AWS via OIDC (no long-lived access keys anywhere)
# ---------------------------------------------------------------------------
resource "aws_iam_openid_connect_provider" "github" {
  count = var.create_github_oidc_provider ? 1 : 0

  url            = "https://token.actions.githubusercontent.com"
  client_id_list = ["sts.amazonaws.com"]
  # AWS no longer checks these for GitHub, but the API still accepts them.
  thumbprint_list = [
    "6938fd4d98bab03faadb97b34396831e3780aea1",
    "1c58a3a8518e8759bf075b76b750d4f2df264fcd",
  ]
}

data "aws_iam_openid_connect_provider" "github" {
  count = var.create_github_oidc_provider ? 0 : 1
  url   = "https://token.actions.githubusercontent.com"
}

locals {
  oidc_provider_arn = var.create_github_oidc_provider ? aws_iam_openid_connect_provider.github[0].arn : data.aws_iam_openid_connect_provider.github[0].arn

  site_bucket_arn  = "arn:aws:s3:::${var.site_bucket_name}"
  state_bucket_arn = aws_s3_bucket.tfstate.arn
}

data "aws_iam_policy_document" "trust_pull_request" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type        = "Federated"
      identifiers = [local.oidc_provider_arn]
    }
    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }
    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:${var.github_repo}:pull_request"]
    }
  }
}

data "aws_iam_policy_document" "trust_main_branch" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type        = "Federated"
      identifiers = [local.oidc_provider_arn]
    }
    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }
    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:${var.github_repo}:ref:refs/heads/main"]
    }
  }
}

# ---- Plan role: read-only, used on pull requests --------------------------
data "aws_iam_policy_document" "plan" {
  statement {
    sid       = "ReadState"
    actions   = ["s3:GetObject", "s3:ListBucket"]
    resources = [local.state_bucket_arn, "${local.state_bucket_arn}/*"]
  }
  statement {
    sid       = "ReadSiteBucketConfig"
    actions   = ["s3:Get*", "s3:List*"]
    resources = [local.site_bucket_arn]
  }
  statement {
    sid = "ReadEdgeAndDns"
    actions = [
      "cloudfront:Get*", "cloudfront:List*", "cloudfront:Describe*",
      "acm:Describe*", "acm:List*", "acm:Get*",
      "route53:Get*", "route53:List*",
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role" "plan" {
  name                 = "github-portfolio-plan"
  assume_role_policy   = data.aws_iam_policy_document.trust_pull_request.json
  max_session_duration = 3600
}

resource "aws_iam_role_policy" "plan" {
  name   = "terraform-plan"
  role   = aws_iam_role.plan.id
  policy = data.aws_iam_policy_document.plan.json
}

# ---- Deploy role: applies infra/site and uploads the site, main only -----
# Deliberately has NO IAM permissions, so a compromised pipeline cannot
# grant itself more access.
data "aws_iam_policy_document" "deploy" {
  statement {
    sid       = "StateBucketList"
    actions   = ["s3:ListBucket"]
    resources = [local.state_bucket_arn]
  }
  statement {
    sid       = "StateReadWriteLock"
    actions   = ["s3:GetObject", "s3:PutObject", "s3:DeleteObject"]
    resources = ["${local.state_bucket_arn}/site/*"]
  }
  statement {
    sid       = "ManageSiteBucket"
    actions   = ["s3:*"]
    resources = [local.site_bucket_arn, "${local.site_bucket_arn}/*"]
  }
  statement {
    sid       = "ManageCdnAndCert"
    actions   = ["cloudfront:*", "acm:*"]
    resources = ["*"]
  }
  statement {
    sid       = "ManageRecordsInZone"
    actions   = ["route53:ChangeResourceRecordSets", "route53:Get*", "route53:List*"]
    resources = [aws_route53_zone.site.arn]
  }
  statement {
    sid       = "Route53Global"
    actions   = ["route53:GetChange", "route53:ListHostedZones", "route53:ListHostedZonesByName"]
    resources = ["*"]
  }
}

resource "aws_iam_role" "deploy" {
  name                 = "github-portfolio-deploy"
  assume_role_policy   = data.aws_iam_policy_document.trust_main_branch.json
  max_session_duration = 3600
}

resource "aws_iam_role_policy" "deploy" {
  name   = "terraform-apply-and-publish"
  role   = aws_iam_role.deploy.id
  policy = data.aws_iam_policy_document.deploy.json
}
