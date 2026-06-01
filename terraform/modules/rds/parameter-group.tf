# Dedicated parameter group so connection limits, statement logging, and the
# force-SSL flag are versioned in code rather than tuned in the console.
# Replicas inherit their source's parameter group, so we only create one on
# the primary (replicate_source_db_arn == null).
resource "aws_db_parameter_group" "this" {
  count = var.replicate_source_db_arn == null ? 1 : 0

  name   = "${var.name}-pg"
  family = var.parameter_group_family

  dynamic "parameter" {
    for_each = var.db_parameters
    content {
      name  = parameter.key
      value = parameter.value
    }
  }

  tags = var.tags

  lifecycle {
    create_before_destroy = true
  }
}
