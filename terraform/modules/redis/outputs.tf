output "configuration_endpoint" {
  value = aws_elasticache_replication_group.this.configuration_endpoint_address
}
output "security_group_id" {
  value = module.sg.security_group_id
}
