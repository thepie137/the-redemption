# Global cluster shell + TH primary regional cluster.
resource "aws_docdb_global_cluster" "redemption" {
  global_cluster_identifier = "${var.project}-${var.environment}-mongo"
  engine                    = "docdb"
  engine_version            = var.docdb_th.engine_version
  storage_encrypted         = true
  deletion_protection       = true
}

module "docdb_th" {
  source = "./modules/docdb"

  name                      = "${local.name_th}-mongo"
  vpc_id                    = module.vpc_th.vpc_id
  subnet_ids                = module.vpc_th.data_subnet_ids
  source_security_group_ids = [module.eks_th.cluster_primary_security_group_id]

  kms_key_arn       = module.kms_th.key_arns["docdb"]
  global_cluster_id = aws_docdb_global_cluster.redemption.id
  is_primary        = true

  engine_version = var.docdb_th.engine_version
  instance_class = var.docdb_th.instance_class
  instance_count = var.docdb_th.instance_count

  tags = local.common_tags
}
