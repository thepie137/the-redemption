module "waf_th" {
  source = "./modules/waf"

  name = local.name_th
  tags = local.common_tags
}
