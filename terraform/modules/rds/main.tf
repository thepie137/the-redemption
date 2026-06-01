locals {
  is_replica = var.replicate_source_db_arn != null
}

resource "aws_db_instance" "this" {
  identifier = var.name

  # --- primary-only attributes ---
  engine               = local.is_replica ? null : "postgres"
  engine_version       = local.is_replica ? null : var.engine_version
  allocated_storage    = local.is_replica ? null : var.allocated_storage
  db_subnet_group_name = aws_db_subnet_group.this.name
  parameter_group_name = local.is_replica ? null : aws_db_parameter_group.this[0].name
  username             = local.is_replica ? null : var.username

  # RDS-managed master password lands in Secrets Manager automatically and
  # rotates without a custom Lambda. Replicas inherit credentials from source.
  manage_master_user_password   = local.is_replica ? null : var.manage_master_password
  master_user_secret_kms_key_id = local.is_replica ? null : var.master_password_secret_kms_key_arn

  multi_az                = local.is_replica ? false : var.multi_az
  backup_retention_period = local.is_replica ? 7 : var.backup_retention_period

  # --- replica-only attribute ---
  replicate_source_db = var.replicate_source_db_arn

  # --- common attributes ---
  instance_class               = var.instance_class
  storage_type                 = "gp3"
  storage_encrypted            = true
  kms_key_id                   = var.kms_key_arn
  performance_insights_enabled = true
  vpc_security_group_ids       = [module.sg.security_group_id]
  port                         = var.port
  publicly_accessible          = false

  deletion_protection      = true
  skip_final_snapshot      = local.is_replica
  final_snapshot_identifier = local.is_replica ? null : "${var.name}-final"

  enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]

  tags = merge(var.tags, { Role = local.is_replica ? "replica" : "primary" })

  lifecycle {
    ignore_changes = [final_snapshot_identifier]
  }
}
