variable "name" {
  description = "Repository name prefix; the repo is <name>/redemption."
  type        = string
}
variable "kms_key_arn" { type = string }
variable "replication_dr_region" {
  description = "Destination region for registry CRR. Empty string disables replication."
  type        = string
  default     = ""
}
variable "tags" { type = map(string) }
