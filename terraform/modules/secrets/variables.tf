variable "name" {
  description = "Secret name prefix, e.g. redemption/prod."
  type        = string
}

variable "kms_key_arn" {
  description = "KMS key ARN (local region) used to encrypt these secrets."
  type        = string
}

variable "secrets" {
  description = <<-EOT
    Map of secret short-name => config.
      description     : human description
      generate_random : if true, seed an initial 32-char random value
      initial_value   : optional explicit JSON string (ignored if generate_random)
  EOT
  type = map(object({
    description     = optional(string, "")
    generate_random = optional(bool, false)
    initial_value   = optional(string, null)
  }))
}

variable "replica_regions" {
  description = "List of { region, kms_key_arn } to replicate every secret into (DR). Empty = no replication."
  type = list(object({
    region      = string
    kms_key_arn = string
  }))
  default = []
}

variable "recovery_window_in_days" {
  type    = number
  default = 30
}

variable "tags" {
  type = map(string)
}
