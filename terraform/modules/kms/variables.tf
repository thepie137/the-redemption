variable "name" {
  description = "Resource name prefix, e.g. redemption-prod-th."
  type        = string
}

variable "keys" {
  description = <<-EOT
    Map of logical key name => description. One customer-managed KMS key is
    created per entry, each with rotation enabled and an alias of
    alias/<name>-<key>. Downstream modules consume the ARNs by key name.
  EOT
  type        = map(string)
  default = {
    eks     = "EKS secret envelope encryption"
    rds     = "RDS PostgreSQL storage encryption"
    docdb   = "DocumentDB storage encryption"
    redis   = "ElastiCache at-rest encryption"
    s3      = "S3 bucket SSE"
    secrets = "Secrets Manager secret encryption"
    ebs     = "EKS node EBS volume encryption"
    msk     = "MSK broker storage encryption"
    logs    = "CloudWatch Logs encryption"
  }
}

variable "deletion_window_in_days" {
  type    = number
  default = 30
}

variable "tags" {
  type = map(string)
}
