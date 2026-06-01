output "key_arns" {
  description = "Map of logical key name => KMS key ARN."
  value       = { for k, v in aws_kms_key.this : k => v.arn }
}

output "key_ids" {
  value = { for k, v in aws_kms_key.this : k => v.key_id }
}

output "alias_names" {
  value = { for k, v in aws_kms_alias.this : k => v.name }
}
