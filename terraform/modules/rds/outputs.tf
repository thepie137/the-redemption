output "db_instance_arn" { value = aws_db_instance.this.arn }
output "address" { value = aws_db_instance.this.address }
output "port" { value = aws_db_instance.this.port }
output "security_group_id" { value = module.sg.security_group_id }

output "master_user_secret_arn" {
  description = "ARN of the RDS-managed master password secret (primary only; null on replicas)."
  value       = try(aws_db_instance.this.master_user_secret[0].secret_arn, null)
}
