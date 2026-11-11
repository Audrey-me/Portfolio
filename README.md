# kosisochukwuakaeze.com

Static portfolio site on AWS, provisioned with Terraform and deployed by GitHub Actions.

```
Visitor ─▶ Route 53 ─▶ CloudFront (HTTPS, ACM cert, security headers, www→apex) ─▶ private S3 bucket
                                            ▲
GitHub Actions ──OIDC──▶ IAM role ──────────┘  terraform apply · s3 sync · invalidate
```

| Path | What |
|---|---|
| `site/` | The website files, the only thing uploaded to S3 |
| `infra/bootstrap/` | One-time: state bucket, Route 53 zone, GitHub OIDC provider, CI roles. Local state. |
| `infra/site/` | S3 bucket, ACM certificate, CloudFront, DNS records. Remote state, applied by CI. |
| `.github/workflows/deploy.yml` | PR → `terraform plan` (read-only role). Push to `main` → apply + publish. |

## Security choices
- **No AWS keys in GitHub.** Actions authenticates through OIDC. The trust policies only accept this repo's `main` branch (deploy) or its pull requests (plan).
- **The deploy role has no IAM permissions**, so a compromised pipeline can't escalate its own access.
- **Private bucket.** Only this CloudFront distribution can read it (Origin Access Control plus `AWS:SourceArn`). HTTPS is enforced everywhere.
- Encrypted, versioned state with S3-native locking.

## First-time setup
1. Upgrade Terraform to 1.10 or later (`brew install hashicorp/tap/terraform`) and sign in to AWS (`aws login` or `aws configure sso`).
2. `cd infra/bootstrap && terraform init && terraform apply`
3. At your domain registrar, replace the nameservers with the four in the `nameservers` output. Wait until `dig NS kosisochukwuakaeze.com +short` shows the AWS ones.
4. In GitHub, go to **Settings → Secrets and variables → Actions → Variables** and add `AWS_PLAN_ROLE_ARN` and `AWS_DEPLOY_ROLE_ARN` from the outputs.
5. Push to `main`. The first run takes about 5–15 minutes while the certificate validates and CloudFront deploys.

After that, every push to `main` publishes the site.
