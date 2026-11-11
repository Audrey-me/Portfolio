output "nameservers" {
  description = "Set these four as the nameservers at your domain registrar"
  value       = aws_route53_zone.site.name_servers
}

output "plan_role_arn" {
  description = "GitHub Actions secret AWS_PLAN_ROLE_ARN"
  value       = aws_iam_role.plan.arn
}

output "deploy_role_arn" {
  description = "GitHub Actions secret AWS_DEPLOY_ROLE_ARN"
  value       = aws_iam_role.deploy.arn
}

output "state_bucket" {
  value = aws_s3_bucket.tfstate.bucket
}

output "account_id" {
  value = data.aws_caller_identity.current.account_id
}
