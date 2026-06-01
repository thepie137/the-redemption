# =====================================================================
# PROD · Thailand (Bangkok, ap-southeast-7) — PRIMARY
# Apply together with prod-sg.tfvars:
#   terraform apply \
#     -var-file=environments/prod-th.tfvars \
#     -var-file=environments/prod-sg.tfvars
# =====================================================================

# ----- global (shared; defined once here in the -th file) -----
project     = "redemption"
environment = "prod"
th_region   = "ap-southeast-7"
sg_region   = "ap-southeast-1"
enable_dr   = true

dns = {
  zone_name    = "loyalty.example"
  app_hostname = "redemption.loyalty.example"
}

# Populate after the first apply, once the ALBs exist (see README two-step):
# alb = {
#   th_dns = "...elb.amazonaws.com"  th_zone_id = "Z..."
#   sg_dns = "...elb.amazonaws.com"  sg_zone_id = "Z..."
# }

admin_principal_arns     = ["arn:aws:iam::ACCOUNT_ID:role/sso-sre-admin"]
developer_principal_arns = ["arn:aws:iam::ACCOUNT_ID:role/sso-developer"]

# ----- vpc -----
vpc_th = {
  cidr     = "10.40.0.0/16"  # nodes: 10.x
  pod_cidr = "100.64.0.0/16" # pods:  100.x (VPC CNI custom networking)
  azs      = ["ap-southeast-7a", "ap-southeast-7b", "ap-southeast-7c"]
}

# ----- eks -----
eks_th = {
  cluster_version            = "1.30"
  system_node_instance_types = ["m6i.large"]
  system_node_min_size       = 3
  system_node_max_size       = 6
  enable_public_endpoint     = false
  allowed_admin_cidrs        = []
}

# ----- rds (PostgreSQL) -----
rds_th = {
  instance_class    = "db.r6g.large"
  engine_version    = "16.4"
  allocated_storage = 100
  multi_az          = true
}

# ----- docdb (Mongo-compatible) -----
docdb_th = {
  instance_class = "db.r6g.large"
  instance_count = 3
  engine_version = "5.0.0"
}

# ----- redis -----
redis_th = {
  node_type               = "cache.r6g.large"
  num_node_groups         = 3
  replicas_per_node_group = 1
}

# ----- kafka (MSK) -----
kafka_th = {
  kafka_version        = "3.7.x"
  broker_instance_type = "kafka.m7g.large"
  broker_nodes         = 3
}

# ----- s3 -----
s3_th = {
  bucket_name = "redemption-prod-objects-th"
}
