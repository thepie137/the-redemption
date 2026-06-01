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

variable "node_type" {
  type    = string
  default = "cache.r6g.large"
}
variable "num_node_groups" {
  type    = number
  default = 3
}
variable "replicas_per_node_group" {
  type    = number
  default = 1
}
variable "engine_version" {
  type    = string
  default = "7.1"
}

variable "role" {
  description = "\"primary\" (hot) or \"cold-standby\" (DR, empty). Tagging only — cluster config is identical."
  type        = string
  default     = "primary"
}

variable "tags" { type = map(string) }
