# Secondary CIDR + pod subnets for VPC CNI custom networking.
# Nodes keep their 10.x addresses (private_app subnets); pods are assigned
# 100.x addresses from these subnets via per-AZ ENIConfig CRDs (applied in
# the cluster — see kubernetes/networking/eniconfig.yaml).
resource "aws_vpc_ipv4_cidr_block_association" "pods" {
  vpc_id     = aws_vpc.this.id
  cidr_block = var.pod_cidr
}

resource "aws_subnet" "pod" {
  for_each = { for i, az in var.azs : az => i }

  vpc_id            = aws_vpc.this.id
  cidr_block        = local.pod_subnets[each.value]
  availability_zone = each.key

  tags = merge(var.tags, {
    Name                                        = "${var.name}-pod-${each.key}"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    tier                                        = "pods"
  })

  depends_on = [aws_vpc_ipv4_cidr_block_association.pods]
}

# Pod subnets egress through the same per-AZ NAT as the app subnets.
resource "aws_route_table_association" "pod" {
  for_each       = aws_subnet.pod
  subnet_id      = each.value.id
  route_table_id = aws_route_table.private[each.key].id
}
