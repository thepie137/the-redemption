# =====================================================================
# PROD · Singapore (ap-southeast-1) — DR / STANDBY
# Only the SG-suffixed module sections live here. Shared/global values
# are in prod-th.tfvars. Always apply both files together.
# =====================================================================

# ----- vpc -----
vpc_sg = {
  cidr     = "10.140.0.0/16" # nodes: 10.x
  pod_cidr = "100.65.0.0/16" # pods:  100.x (distinct from TH)
  azs      = ["ap-southeast-1a", "ap-southeast-1b", "ap-southeast-1c"]
}

# ----- eks (standby: system NG only; app scaled to 0) -----
eks_sg = {
  cluster_version            = "1.30"
  system_node_instance_types = ["t3.large"]
  system_node_min_size       = 2
  system_node_max_size       = 4
  enable_public_endpoint     = false
  allowed_admin_cidrs        = []
}

# ----- rds (cross-region replica; engine/storage inherited from TH) -----
rds_sg = {
  instance_class = "db.r6g.large"
}

# ----- docdb (global-cluster secondary) -----
docdb_sg = {
  instance_class = "db.r6g.large"
  instance_count = 2
}

# ----- redis (cold standby, empty) -----
redis_sg = {
  node_type               = "cache.r6g.large"
  num_node_groups         = 3
  replicas_per_node_group = 1
}

# ----- kafka (cold standby, empty) -----
kafka_sg = {
  kafka_version        = "3.7.x"
  broker_instance_type = "kafka.m7g.large"
  broker_nodes         = 3
}

# ----- s3 (CRR destination) -----
s3_sg = {
  bucket_name = "redemption-prod-objects-sg"
}
