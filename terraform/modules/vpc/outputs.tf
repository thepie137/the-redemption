output "vpc_id" {
  value = aws_vpc.this.id
}

output "private_subnet_ids" {
  value = [for s in aws_subnet.private_app : s.id]
}

output "public_subnet_ids" {
  value = [for s in aws_subnet.public : s.id]
}

output "data_subnet_ids" {
  value = [for s in aws_subnet.private_data : s.id]
}

# Pod subnets (100.x) keyed by AZ — consumed by the per-AZ ENIConfig.
output "pod_subnet_ids_by_az" {
  value = { for az, s in aws_subnet.pod : az => s.id }
}

output "pod_subnet_ids" {
  value = [for s in aws_subnet.pod : s.id]
}

output "pod_cidr" {
  value = var.pod_cidr
}
