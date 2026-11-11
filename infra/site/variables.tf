variable "domain_name" {
  description = "Apex domain. Its Route 53 zone must already exist (created by infra/bootstrap)."
  type        = string
}

variable "site_bucket_name" {
  description = "Globally unique S3 bucket name for the site files"
  type        = string
}

variable "price_class" {
  description = "PriceClass_All includes edge locations in Africa and South America; PriceClass_100 is North America + Europe only"
  type        = string
  default     = "PriceClass_All"
}
