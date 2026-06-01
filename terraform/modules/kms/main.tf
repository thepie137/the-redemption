data "aws_caller_identity" "current" {}
data "aws_partition" "current" {}

# One customer-managed key per data domain. Customer-managed (not aws/*)
# so we can scope key policies, rotate independently, and produce a clean
# CloudTrail of who decrypted what. Rotation is on for every key.
resource "aws_kms_key" "this" {
  for_each = var.keys

  description             = "${var.name} — ${each.value}"
  enable_key_rotation     = true
  deletion_window_in_days = var.deletion_window_in_days
  multi_region            = false

  # Base policy: account root retains admin; service principals are granted
  # usage via grants created by the consuming services (RDS, S3, etc.).
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "RootAccountAdmin"
        Effect    = "Allow"
        Principal = { AWS = "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:root" }
        Action    = "kms:*"
        Resource  = "*"
      },
      {
        Sid    = "AllowAwsServiceUse"
        Effect = "Allow"
        Principal = {
          Service = [
            "rds.amazonaws.com",
            "elasticache.amazonaws.com",
            "s3.amazonaws.com",
            "secretsmanager.amazonaws.com",
            "logs.amazonaws.com",
            "eks.amazonaws.com",
            "kafka.amazonaws.com",
          ]
        }
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:CreateGrant",
          "kms:DescribeKey",
        ]
        Resource = "*"
      },
    ]
  })

  tags = merge(var.tags, { KeyDomain = each.key })
}

resource "aws_kms_alias" "this" {
  for_each = var.keys

  name          = "alias/${var.name}-${each.key}"
  target_key_id = aws_kms_key.this[each.key].key_id
}
