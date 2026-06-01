# Cold standby MSK (empty). Independent cluster, no MirrorMaker/Replicator —
# events replay from RDS on failover; app points here via a ConfigMap swap.
module "kafka_sg" {
  source    = "./modules/kafka"
  providers = { aws = aws.sg }

  count = var.enable_dr ? 1 : 0

  name                      = "${local.name_sg}-msk"
  vpc_id                    = module.vpc_sg.vpc_id
  subnet_ids                = module.vpc_sg.data_subnet_ids
  source_security_group_ids = [module.eks_sg[0].cluster_primary_security_group_id]

  kms_key_arn = module.kms_sg.key_arns["msk"]

  kafka_version        = var.kafka_sg.kafka_version
  broker_instance_type = var.kafka_sg.broker_instance_type
  broker_nodes         = var.kafka_sg.broker_nodes

  role = "cold-standby"
  tags = local.common_tags
}
