# =====================================================================
# STAGING · Thailand (ap-southeast-7) — PRIMARY
#   terraform apply -var-file=environments/staging-th.tfvars \
#                   -var-file=environments/staging-sg.tfvars
# =====================================================================

project     = "redemption"
environment = "staging"
th_region   = "ap-southeast-7"
sg_region   = "ap-southeast-1"
enable_dr   = true

dns = {
  zone_name    = "staging.loyalty.example"
  app_hostname = "redemption.staging.loyalty.example"
}

admin_principal_arns     = ["arn:aws:iam::ACCOUNT_ID:role/sso-sre-admin"]
developer_principal_arns = ["arn:aws:iam::ACCOUNT_ID:role/sso-developer"]

vpc_th = {
  cidr = "10.50.0.0/16"
  azs  = ["ap-southeast-7a", "ap-southeast-7b", "ap-southeast-7c"]
}

eks_th = {
  cluster_version            = "1.30"
  system_node_instance_types = ["t3.large"]
  system_node_min_size       = 2
  system_node_max_size       = 4
  enable_public_endpoint     = true
  allowed_admin_cidrs        = ["203.0.113.0/24"]
}

rds_th = {
  instance_class    = "db.t4g.large"
  engine_version    = "16.4"
  allocated_storage = 50
  multi_az          = true
}

docdb_th = {
  instance_class = "db.t4g.medium"
  instance_count = 2
  engine_version = "5.0.0"
}

redis_th = {
  node_type               = "cache.t4g.medium"
  num_node_groups         = 2
  replicas_per_node_group = 1
}

kafka_th = {
  kafka_version        = "3.7.x"
  broker_instance_type = "kafka.t3.small"
  broker_nodes         = 3
}

s3_th = {
  bucket_name = "redemption-staging-objects-th"
}
