# ===========================================================================
# Global
# ===========================================================================
variable "project" {
  type    = string
  default = "redemption"
}

variable "environment" {
  description = "dev | staging | prod"
  type        = string
}

variable "th_region" {
  description = "Primary region — Bangkok."
  type        = string
  default     = "ap-southeast-7"
}

variable "sg_region" {
  description = "DR region — Singapore."
  type        = string
  default     = "ap-southeast-1"
}

variable "enable_dr" {
  description = "Provision the Singapore DR stack. Disable for dev to save cost."
  type        = bool
  default     = true
}

variable "tags" {
  type = map(string)
  default = {
    Owner      = "sre-redemption"
    CostCenter = "loyalty-platform"
    Compliance = "pci-dss-relevant"
    ManagedBy  = "terraform"
  }
}

variable "dns" {
  description = "Public DNS config for the Global DNS / failover records."
  type = object({
    zone_name    = string
    app_hostname = string
  })
}

variable "alb" {
  description = <<-EOT
    ALB DNS names + hosted-zone IDs, read back from the cluster Ingress on the
    second apply (the AWS Load Balancer Controller creates the ALBs). Leave
    empty on the first apply — all Route 53 failover records are then skipped.
  EOT
  type = object({
    th_dns     = optional(string, "")
    th_zone_id = optional(string, "")
    sg_dns     = optional(string, "")
    sg_zone_id = optional(string, "")
  })
  default = {}
}

# Principals that receive cluster access via EKS Access Entries (both regions).
variable "admin_principal_arns" {
  description = "IAM/SSO role ARNs granted cluster-admin + SSM node access."
  type        = list(string)
  default     = []
}

variable "developer_principal_arns" {
  description = "IAM/SSO role ARNs granted namespaced edit access."
  type        = list(string)
  default     = []
}

# ===========================================================================
# VPC
# ===========================================================================
variable "vpc_th" {
  type = object({
    cidr     = string           # node/primary space (10.x)
    pod_cidr = optional(string) # pod space (100.x); defaults in module
    azs      = list(string)
  })
}

variable "vpc_sg" {
  type = object({
    cidr     = string
    pod_cidr = optional(string)
    azs      = list(string)
  })
}

# ===========================================================================
# EKS
# ===========================================================================
variable "eks_th" {
  type = object({
    cluster_version            = string
    system_node_instance_types = list(string)
    system_node_min_size       = number
    system_node_max_size       = number
    enable_public_endpoint     = optional(bool, false)
    allowed_admin_cidrs        = optional(list(string), [])
  })
}

variable "eks_sg" {
  type = object({
    cluster_version            = string
    system_node_instance_types = list(string)
    system_node_min_size       = number
    system_node_max_size       = number
    enable_public_endpoint     = optional(bool, false)
    allowed_admin_cidrs        = optional(list(string), [])
  })
}

# ===========================================================================
# RDS (PostgreSQL)
# ===========================================================================
variable "rds_th" {
  type = object({
    instance_class    = string
    engine_version    = string
    allocated_storage = number
    multi_az          = bool
  })
}

variable "rds_sg" {
  description = "DR replica sizing. engine_version/storage inherited from source."
  type = object({
    instance_class = string
  })
}

# ===========================================================================
# DocumentDB (Mongo-compatible)
# ===========================================================================
variable "docdb_th" {
  type = object({
    instance_class = string
    instance_count = number
    engine_version = string
  })
}

variable "docdb_sg" {
  type = object({
    instance_class = string
    instance_count = number
  })
}

# ===========================================================================
# ElastiCache Redis
# ===========================================================================
variable "redis_th" {
  type = object({
    node_type               = string
    num_node_groups         = number
    replicas_per_node_group = number
  })
}

variable "redis_sg" {
  type = object({
    node_type               = string
    num_node_groups         = number
    replicas_per_node_group = number
  })
}

# ===========================================================================
# MSK (Kafka)
# ===========================================================================
variable "kafka_th" {
  type = object({
    kafka_version        = string
    broker_instance_type = string
    broker_nodes         = number
  })
}

variable "kafka_sg" {
  type = object({
    kafka_version        = string
    broker_instance_type = string
    broker_nodes         = number
  })
}

# ===========================================================================
# S3
# ===========================================================================
variable "s3_th" {
  type = object({
    bucket_name = string
  })
}

variable "s3_sg" {
  type = object({
    bucket_name = string
  })
}
