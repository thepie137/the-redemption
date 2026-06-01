module "kafka_th" {
  source = "./modules/kafka"

  name                      = "${local.name_th}-msk"
  vpc_id                    = module.vpc_th.vpc_id
  subnet_ids                = module.vpc_th.data_subnet_ids
  source_security_group_ids = [module.eks_th.cluster_primary_security_group_id]

  kms_key_arn = module.kms_th.key_arns["msk"]

  kafka_version        = var.kafka_th.kafka_version
  broker_instance_type = var.kafka_th.broker_instance_type
  broker_nodes         = var.kafka_th.broker_nodes

  role = "primary"
  tags = local.common_tags
}
