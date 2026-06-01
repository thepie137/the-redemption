module "waf_sg" {
  source    = "./modules/waf"
  providers = { aws = aws.sg }

  count = var.enable_dr ? 1 : 0

  name = local.name_sg
  tags = local.common_tags
}
