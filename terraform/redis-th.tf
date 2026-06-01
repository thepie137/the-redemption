module "redis_th" {
  source = "./modules/redis"

  name                      = "${local.name_th}-redis"
  vpc_id                    = module.vpc_th.vpc_id
  subnet_ids                = module.vpc_th.data_subnet_ids
  source_security_group_ids = [module.eks_th.cluster_primary_security_group_id]

  kms_key_arn = module.kms_th.key_arns["redis"]

  node_type               = var.redis_th.node_type
  num_node_groups         = var.redis_th.num_node_groups
  replicas_per_node_group = var.redis_th.replicas_per_node_group

  role = "primary"
  tags = local.common_tags
}
