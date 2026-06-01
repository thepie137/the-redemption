module "rds_sg" {
  source    = "./modules/rds"
  providers = { aws = aws.sg }

  count = var.enable_dr ? 1 : 0

  name                      = "${local.name_sg}-rds"
  vpc_id                    = module.vpc_sg.vpc_id
  subnet_ids                = module.vpc_sg.data_subnet_ids
  source_security_group_ids = [module.eks_sg[0].cluster_primary_security_group_id]

  kms_key_arn = module.kms_sg.key_arns["rds"]

  instance_class = var.rds_sg.instance_class

  # Cross-region read replica of the TH primary. Promoted to writer in
  # failover step 2 of runbook RD-01.
  replicate_source_db_arn = module.rds_th.db_instance_arn

  tags = local.common_tags
}
