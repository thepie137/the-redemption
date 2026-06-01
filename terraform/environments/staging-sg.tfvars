# =====================================================================
# STAGING · Singapore (ap-southeast-1) — DR / STANDBY
# =====================================================================

vpc_sg = {
  cidr = "10.150.0.0/16"
  azs  = ["ap-southeast-1a", "ap-southeast-1b", "ap-southeast-1c"]
}

eks_sg = {
  cluster_version            = "1.30"
  system_node_instance_types = ["t3.large"]
  system_node_min_size       = 2
  system_node_max_size       = 3
  enable_public_endpoint     = true
  allowed_admin_cidrs        = ["203.0.113.0/24"]
}

rds_sg = {
  instance_class = "db.t4g.large"
}

docdb_sg = {
  instance_class = "db.t4g.medium"
  instance_count = 1
}

redis_sg = {
  node_type               = "cache.t4g.medium"
  num_node_groups         = 2
  replicas_per_node_group = 1
}

kafka_sg = {
  kafka_version        = "3.7.x"
  broker_instance_type = "kafka.t3.small"
  broker_nodes         = 3
}

s3_sg = {
  bucket_name = "redemption-staging-objects-sg"
}
