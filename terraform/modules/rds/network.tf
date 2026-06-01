resource "aws_db_subnet_group" "this" {
  name       = var.name
  subnet_ids = var.subnet_ids
  tags       = merge(var.tags, { Name = var.name })
}

# Dedicated security group for this component, allowing connection from the
# EKS pods (source SG reference) — works across the 100.64.0.0/16 pod CIDR.
module "sg" {
  source = "../security-group"

  name                      = "${var.name}-sg"
  description               = "Ingress to ${var.name} from EKS pods only."
  vpc_id                    = var.vpc_id
  ingress_port              = var.port
  source_security_group_ids = var.source_security_group_ids
  allowed_cidrs             = var.allowed_cidrs
  tags                      = var.tags
}
