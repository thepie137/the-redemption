module "rds_th" {
  source = "./modules/rds"

  name                      = "${local.name_th}-rds"
  vpc_id                    = module.vpc_th.vpc_id
  subnet_ids                = module.vpc_th.data_subnet_ids
  source_security_group_ids = [module.eks_th.cluster_primary_security_group_id]

  kms_key_arn = module.kms_th.key_arns["rds"]

  engine_version    = var.rds_th.engine_version
  instance_class    = var.rds_th.instance_class
  allocated_storage = var.rds_th.allocated_storage
  multi_az          = var.rds_th.multi_az

  # RDS manages the master password in Secrets Manager, encrypted with the
  # rds KMS key, and rotates it natively.
  manage_master_password             = true
  master_password_secret_kms_key_arn = module.kms_th.key_arns["rds"]

  tags = local.common_tags
}
