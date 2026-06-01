variable "name" { type = string }

variable "vpc_id" { type = string }
variable "subnet_ids" { type = list(string) }
variable "source_security_group_ids" {
  type    = list(string)
  default = []
}
variable "allowed_cidrs" {
  type    = list(string)
  default = []
}

variable "kms_key_arn" { type = string }

variable "global_cluster_id" {
  description = "DocumentDB global cluster identifier this regional cluster joins."
  type        = string
}

variable "is_primary" {
  description = "True for the writer region (creates master credentials)."
  type        = bool
}

variable "engine_version" {
  type    = string
  default = "5.0.0"
}

variable "instance_class" {
  type    = string
  default = "db.r6g.large"
}

variable "instance_count" {
  type    = number
  default = 3
}

variable "master_password_secret_arn" {
  description = "Optional: not used directly; credentials are generated and should be stored in Secrets Manager by the caller."
  type        = string
  default     = null
}

variable "tags" { type = map(string) }
