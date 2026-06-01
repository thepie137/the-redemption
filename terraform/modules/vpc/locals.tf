# Within the primary CIDR (10.x) we split each AZ into three /20s: public
# (NAT/ALB), private app (NODES), and private data (RDS/ElastiCache/etc).
# Pods live in a separate secondary CIDR (100.x) — see pod_subnets below — so
# node IPs are 10.x and pod IPs are 100.x.
locals {
  public_subnets = [for i, az in var.azs : cidrsubnet(var.cidr, 4, i)]
  private_app    = [for i, az in var.azs : cidrsubnet(var.cidr, 4, i + 4)]
  private_data   = [for i, az in var.azs : cidrsubnet(var.cidr, 4, i + 8)]

  # Pod subnets, one /20 per AZ carved from the 100.64.0.0/16 secondary CIDR.
  pod_subnets = [for i, az in var.azs : cidrsubnet(var.pod_cidr, 4, i)]
}

data "aws_region" "current" {}
