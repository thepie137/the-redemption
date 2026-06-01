module "vpc_th" {
  source = "./modules/vpc"

  name         = local.name_th
  cidr         = var.vpc_th.cidr
  pod_cidr     = coalesce(var.vpc_th.pod_cidr, "100.64.0.0/16")
  azs          = var.vpc_th.azs
  cluster_name = local.name_th
  tags         = local.common_tags
}
