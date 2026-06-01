module "kms_sg" {
  source    = "./modules/kms"
  providers = { aws = aws.sg }

  name = local.name_sg
  tags = local.common_tags
}
