resource "random_password" "master" {
  count   = var.is_primary ? 1 : 0
  length  = 32
  special = false
}

resource "aws_docdb_cluster" "this" {
  cluster_identifier        = var.name
  engine                    = "docdb"
  engine_version            = var.engine_version
  global_cluster_identifier = var.global_cluster_id

  # Master credentials only on the primary region; the secondary joins the
  # global cluster and replicates at the storage layer.
  master_username = var.is_primary ? "redemption" : null
  master_password = var.is_primary ? random_password.master[0].result : null

  db_subnet_group_name   = aws_docdb_subnet_group.this.name
  vpc_security_group_ids = [module.sg.security_group_id]

  storage_encrypted               = true
  kms_key_id                      = var.kms_key_arn
  backup_retention_period         = var.is_primary ? 35 : null
  preferred_backup_window         = var.is_primary ? "16:00-17:00" : null
  deletion_protection             = true
  skip_final_snapshot             = !var.is_primary
  final_snapshot_identifier       = var.is_primary ? "${var.name}-final" : null
  enabled_cloudwatch_logs_exports = ["audit", "profiler"]

  tags = merge(var.tags, { Role = var.is_primary ? "primary" : "secondary" })

  lifecycle {
    ignore_changes = [master_password, final_snapshot_identifier]
  }
}

resource "aws_docdb_cluster_instance" "this" {
  count              = var.instance_count
  identifier         = "${var.name}-${count.index}"
  cluster_identifier = aws_docdb_cluster.this.id
  instance_class     = var.instance_class
  tags               = var.tags
}
