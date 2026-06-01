module "kms_th" {
  source = "./modules/kms"

  name = local.name_th
  tags = local.common_tags
}
