variable "name" { type = string }
variable "vpc_id" { type = string }
variable "subnet_ids" {
  description = "One private subnet per AZ (MSK places one broker per subnet)."
  type        = list(string)
}
variable "source_security_group_ids" {
  type    = list(string)
  default = []
}
variable "allowed_cidrs" {
  type    = list(string)
  default = []
}
variable "kms_key_arn" { type = string }

variable "kafka_version" {
  type    = string
  default = "3.7.x"
}
variable "broker_instance_type" {
  type    = string
  default = "kafka.m7g.large"
}
variable "broker_nodes" {
  type    = number
  default = 3
}
variable "ebs_volume_size" {
  type    = number
  default = 200
}
variable "role" {
  description = "\"primary\" or \"cold-standby\" — tagging only."
  type        = string
  default     = "primary"
}

variable "tags" { type = map(string) }
