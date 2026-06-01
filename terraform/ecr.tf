# Single ECR registry concern, owned by the primary region (TH) with
# registry-level cross-region replication to SG so the DR cluster can pull.
module "ecr_th" {
  source = "./modules/ecr"

  name                  = local.name_th
  kms_key_arn           = module.kms_th.key_arns["ebs"] # reuse a TH key for image encryption
  replication_dr_region = var.enable_dr ? var.sg_region : ""
  tags                  = local.common_tags
}
