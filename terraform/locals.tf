locals {
  name_th = "${var.project}-${var.environment}-th"
  name_sg = "${var.project}-${var.environment}-sg"

  common_tags = merge(var.tags, {
    Project     = var.project
    Environment = var.environment
  })

  # Secrets the application consumes at runtime (non-DB; the DB master
  # password is managed by RDS directly). External Secrets pulls these.
  app_secrets = {
    runtime = { description = "Redemption app runtime config (API keys, feature flags)", generate_random = false }
    jwt     = { description = "JWT signing key", generate_random = true }
  }
}
