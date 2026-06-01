data "aws_caller_identity" "current" {}

resource "aws_ecr_repository" "redemption" {
  name                 = "${var.name}/redemption"
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration { scan_on_push = true }
  encryption_configuration {
    encryption_type = "KMS"
    kms_key         = var.kms_key_arn
  }

  tags = var.tags
}

resource "aws_ecr_lifecycle_policy" "redemption" {
  repository = aws_ecr_repository.redemption.name
  policy = jsonencode({
    rules = [{
      rulePriority = 1
      description  = "Keep 30 most recent images; older builds are recoverable from the CI artifact store."
      selection = {
        tagStatus   = "any"
        countType   = "imageCountMoreThan"
        countNumber = 30
      }
      action = { type = "expire" }
    }]
  })
}

# Registry-level cross-region replication: a push in the primary region
# auto-mirrors to the DR region within seconds, so the DR cluster never
# reaches back to the primary registry during a failover.
resource "aws_ecr_replication_configuration" "this" {
  count = var.replication_dr_region == "" ? 0 : 1

  replication_configuration {
    rule {
      destination {
        region      = var.replication_dr_region
        registry_id = data.aws_caller_identity.current.account_id
      }
      repository_filter {
        filter      = "${var.name}/"
        filter_type = "PREFIX_MATCH"
      }
    }
  }
}

output "repository_url" { value = aws_ecr_repository.redemption.repository_url }
