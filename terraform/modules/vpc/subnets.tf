resource "aws_subnet" "public" {
  for_each = { for i, az in var.azs : az => i }

  vpc_id                  = aws_vpc.this.id
  cidr_block              = local.public_subnets[each.value]
  availability_zone       = each.key
  map_public_ip_on_launch = false

  tags = merge(var.tags, {
    Name                                        = "${var.name}-public-${each.key}"
    "kubernetes.io/role/elb"                    = "1"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  })
}

resource "aws_subnet" "private_app" {
  for_each = { for i, az in var.azs : az => i }

  vpc_id            = aws_vpc.this.id
  cidr_block        = local.private_app[each.value]
  availability_zone = each.key

  tags = merge(var.tags, {
    Name                                        = "${var.name}-app-${each.key}"
    "kubernetes.io/role/internal-elb"           = "1"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "karpenter.sh/discovery"                    = var.cluster_name
  })
}

resource "aws_subnet" "private_data" {
  for_each = { for i, az in var.azs : az => i }

  vpc_id            = aws_vpc.this.id
  cidr_block        = local.private_data[each.value]
  availability_zone = each.key

  tags = merge(var.tags, { Name = "${var.name}-data-${each.key}" })
}
