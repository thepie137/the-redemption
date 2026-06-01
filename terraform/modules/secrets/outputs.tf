output "secret_arns" {
  description = "Map of short-name => secret ARN."
  value       = { for k, v in aws_secretsmanager_secret.this : k => v.arn }
}

output "secret_arn_list" {
  description = "Flat list of secret ARNs, for IAM resource scoping."
  value       = [for v in aws_secretsmanager_secret.this : v.arn]
}
