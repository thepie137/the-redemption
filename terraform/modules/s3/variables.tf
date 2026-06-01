variable "bucket_name" {
  description = "Globally-unique bucket name."
  type        = string
}

variable "kms_key_arn" {
  description = "KMS key for SSE-KMS."
  type        = string
}

variable "tags" { type = map(string) }
