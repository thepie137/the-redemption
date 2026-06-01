resource "aws_docdb_subnet_group" "this" {
  name       = var.name
  subnet_ids = var.subnet_ids
  tags       = var.tags
}

module "sg" {
  source = "../security-group"

  name                      = "${var.name}-sg"
  description               = "Ingress to ${var.name} from EKS pods only."
  vpc_id                    = var.vpc_id
  ingress_port              = 27017
  source_security_group_ids = var.source_security_group_ids
  allowed_cidrs             = var.allowed_cidrs
  tags                      = var.tags
}
