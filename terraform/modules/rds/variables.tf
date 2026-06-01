variable "name" {
  description = "Identifier prefix, e.g. redemption-prod-th-rds."
  type        = string
}

variable "vpc_id" { type = string }
variable "subnet_ids" {
  description = "Data-subnet IDs for the DB subnet group."
  type        = list(string)
}
variable "source_security_group_ids" {
  description = "Security groups allowed to connect — the EKS pod/cluster SG."
  type        = list(string)
  default     = []
}
variable "allowed_cidrs" {
  description = "Optional extra CIDRs allowed to the DB port."
  type        = list(string)
  default     = []
}

variable "kms_key_arn" {
  description = "KMS key for storage encryption."
  type        = string
}

variable "engine_version" {
  type    = string
  default = "16.4"
}
variable "parameter_group_family" {
  type    = string
  default = "postgres16"
}
variable "instance_class" {
  type    = string
  default = "db.r6g.large"
}
variable "allocated_storage" {
  type    = number
  default = 100
}
variable "multi_az" {
  type    = bool
  default = true
}
variable "port" {
  type    = number
  default = 5432
}

variable "username" {
  type    = string
  default = "redemption"
}

variable "manage_master_password" {
  description = "If true (primary), RDS manages the master password in Secrets Manager. Replicas must set false."
  type        = bool
  default     = true
}

variable "master_password_secret_kms_key_arn" {
  description = "KMS key for the RDS-managed master user secret (primary only)."
  type        = string
  default     = null
}

variable "replicate_source_db_arn" {
  description = "ARN of the source DB to replicate from. Set on the DR replica; null on the primary."
  type        = string
  default     = null
}

variable "backup_retention_period" {
  type    = number
  default = 35
}

variable "db_parameters" {
  description = "Map of parameter-group settings to override."
  type        = map(string)
  default = {
    "log_min_duration_statement" = "500"
    "rds.force_ssl"              = "1"
  }
}

variable "tags" { type = map(string) }
