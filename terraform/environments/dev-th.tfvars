# =====================================================================
# DEV · single-region (no DR). enable_dr = false, so the SG stack is not
# created — but the *_sg variables are still required by Terraform, so
# dev-sg.tfvars must still be supplied (its values are simply unused).
#   terraform apply -var-file=environments/dev-th.tfvars \
#                   -var-file=environments/dev-sg.tfvars
# =====================================================================

project     = "redemption"
environment = "dev"
th_region   = "ap-southeast-1" # dev runs in Singapore only
sg_region   = "ap-southeast-1"
enable_dr   = false

dns = {
  zone_name    = "dev.loyalty.example"
  app_hostname = "redemption.dev.loyalty.example"
}

admin_principal_arns     = ["arn:aws:iam::ACCOUNT_ID:role/sso-sre-admin"]
developer_principal_arns = ["arn:aws:iam::ACCOUNT_ID:role/sso-developer"]

vpc_th = {
  cidr = "10.60.0.0/16"
  azs  = ["ap-southeast-1a", "ap-southeast-1b", "ap-southeast-1c"]
}

eks_th = {
  cluster_version            = "1.30"
  system_node_instance_types = ["t3.medium"]
  system_node_min_size       = 2
  system_node_max_size       = 3
  enable_public_endpoint     = true
  allowed_admin_cidrs        = ["203.0.113.0/24"]
}

rds_th = {
  instance_class    = "db.t4g.medium"
  engine_version    = "16.4"
  allocated_storage = 20
  multi_az          = false
}

docdb_th = {
  instance_class = "db.t4g.medium"
  instance_count = 1
  engine_version = "5.0.0"
}

redis_th = {
  node_type               = "cache.t4g.micro"
  num_node_groups         = 1
  replicas_per_node_group = 0
}

kafka_th = {
  kafka_version        = "3.7.x"
  broker_instance_type = "kafka.t3.small"
  broker_nodes         = 3
}

s3_th = {
  bucket_name = "redemption-dev-objects-th"
}
