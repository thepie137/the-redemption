# App runtime secrets live in TH and replicate to SG (when DR is enabled).
# The DB master password is NOT here — RDS manages that secret itself in
# each region (see rds-th.tf manage_master_user_password).
module "secrets_th" {
  source = "./modules/secrets"

  name        = "redemption/${var.environment}"
  kms_key_arn = module.kms_th.key_arns["secrets"]
  secrets     = local.app_secrets

  replica_regions = var.enable_dr ? [{
    region      = var.sg_region
    kms_key_arn = module.kms_sg.key_arns["secrets"]
  }] : []

  tags = local.common_tags
}
