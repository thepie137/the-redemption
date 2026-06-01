module "vpc_sg" {
  source    = "./modules/vpc"
  providers = { aws = aws.sg }

  name         = local.name_sg
  cidr         = var.vpc_sg.cidr
  pod_cidr     = coalesce(var.vpc_sg.pod_cidr, "100.64.0.0/16")
  azs          = var.vpc_sg.azs
  cluster_name = local.name_sg
  tags         = local.common_tags
}
