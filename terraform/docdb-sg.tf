module "docdb_sg" {
  source    = "./modules/docdb"
  providers = { aws = aws.sg }

  count = var.enable_dr ? 1 : 0

  name                      = "${local.name_sg}-mongo"
  vpc_id                    = module.vpc_sg.vpc_id
  subnet_ids                = module.vpc_sg.data_subnet_ids
  source_security_group_ids = [module.eks_sg[0].cluster_primary_security_group_id]

  kms_key_arn       = module.kms_sg.key_arns["docdb"]
  global_cluster_id = aws_docdb_global_cluster.redemption.id
  is_primary        = false

  engine_version = var.docdb_th.engine_version
  instance_class = var.docdb_sg.instance_class
  instance_count = var.docdb_sg.instance_count

  tags = local.common_tags

  # The secondary cluster can only join once the primary's instances exist.
  depends_on = [module.docdb_th]
}
