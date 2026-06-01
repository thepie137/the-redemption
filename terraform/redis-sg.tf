# Cold standby Redis (empty). Not a Global Datastore replica — cache is
# regenerable from RDS + DocumentDB, so it's preloaded on failover instead.
module "redis_sg" {
  source    = "./modules/redis"
  providers = { aws = aws.sg }

  count = var.enable_dr ? 1 : 0

  name                      = "${local.name_sg}-redis"
  vpc_id                    = module.vpc_sg.vpc_id
  subnet_ids                = module.vpc_sg.data_subnet_ids
  source_security_group_ids = [module.eks_sg[0].cluster_primary_security_group_id]

  kms_key_arn = module.kms_sg.key_arns["redis"]

  node_type               = var.redis_sg.node_type
  num_node_groups         = var.redis_sg.num_node_groups
  replicas_per_node_group = var.redis_sg.replicas_per_node_group

  role = "cold-standby"
  tags = local.common_tags
}
