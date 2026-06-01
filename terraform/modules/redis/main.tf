resource "aws_elasticache_subnet_group" "this" {
  name       = var.name
  subnet_ids = var.subnet_ids
  tags       = var.tags
}

module "sg" {
  source = "../security-group"

  name                      = "${var.name}-sg"
  description               = "Ingress to ${var.name} from EKS pods only."
  vpc_id                    = var.vpc_id
  ingress_port              = 6379
  source_security_group_ids = var.source_security_group_ids
  allowed_cidrs             = var.allowed_cidrs
  tags                      = var.tags
}

# Cluster config is identical between the hot primary (TH) and the cold
# standby (SG). The DR copy is intentionally NOT a Global Datastore replica:
# cache contents are regenerable from RDS + DocumentDB, so we warm it on
# failover (runbook RD-01 step 3b) rather than pay for cross-region replication.
resource "aws_elasticache_replication_group" "this" {
  replication_group_id = var.name
  description          = "${var.role} Redis for ${var.name}"

  engine               = "redis"
  engine_version       = var.engine_version
  node_type            = var.node_type
  port                 = 6379
  parameter_group_name = "default.redis7.cluster.on"

  num_node_groups         = var.num_node_groups
  replicas_per_node_group = var.replicas_per_node_group

  automatic_failover_enabled = true
  multi_az_enabled           = true

  at_rest_encryption_enabled = true
  transit_encryption_enabled = true
  kms_key_id                 = var.kms_key_arn

  subnet_group_name  = aws_elasticache_subnet_group.this.name
  security_group_ids = [module.sg.security_group_id]

  snapshot_retention_limit = var.role == "primary" ? 7 : 0

  tags = merge(var.tags, { Role = var.role })
}
