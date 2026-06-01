# Secrets Manager secrets, encrypted with a customer-managed KMS key and
# optionally replicated cross-region for DR. External Secrets Operator in
# the cluster pulls these into Kubernetes Secrets (refresh 1h); the app's
# IRSA / Pod Identity role is granted GetSecretValue on these ARNs only.
resource "aws_secretsmanager_secret" "this" {
  for_each = var.secrets

  name        = "${var.name}/${each.key}"
  description = each.value.description
  kms_key_id  = var.kms_key_arn

  recovery_window_in_days = var.recovery_window_in_days

  dynamic "replica" {
    for_each = var.replica_regions
    content {
      region     = replica.value.region
      kms_key_id = replica.value.kms_key_arn
    }
  }

  tags = merge(var.tags, { Secret = each.key })
}

# Seed an initial value so the secret is resolvable on first deploy.
# generate_random produces a 32-char alnum string wrapped as {"value": "..."}.
# Day-2 rotation (Lambda / managed RDS rotation) takes over from here, so we
# ignore drift on the secret string.
resource "random_password" "this" {
  for_each = { for k, v in var.secrets : k => v if v.generate_random }
  length   = 32
  special  = false
}

resource "aws_secretsmanager_secret_version" "this" {
  for_each = var.secrets

  secret_id = aws_secretsmanager_secret.this[each.key].id
  secret_string = each.value.generate_random ? jsonencode({
    value = random_password.this[each.key].result
  }) : coalesce(each.value.initial_value, jsonencode({ value = "REPLACE_ME" }))

  lifecycle {
    ignore_changes = [secret_string]
  }
}
