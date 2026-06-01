output "endpoint" { value = aws_docdb_cluster.this.endpoint }
output "reader_endpoint" { value = aws_docdb_cluster.this.reader_endpoint }
output "cluster_id" { value = aws_docdb_cluster.this.id }
output "security_group_id" { value = module.sg.security_group_id }
output "master_password" {
  value     = var.is_primary ? random_password.master[0].result : null
  sensitive = true
}
