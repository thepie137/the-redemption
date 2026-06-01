variable "name" {
  description = "Security group name, e.g. redemption-prod-th-rds."
  type        = string
}

variable "vpc_id" { type = string }

variable "description" {
  type    = string
  default = "Managed by Terraform"
}

variable "ingress_port" {
  description = "TCP port this component listens on (e.g. 5432, 27017, 6379, 9098)."
  type        = number
}

variable "ingress_port_to" {
  description = "Optional end of a port range. Defaults to ingress_port (single port)."
  type        = number
  default     = null
}

variable "source_security_group_ids" {
  description = <<-EOT
    Source security groups allowed to connect — typically the EKS pod/cluster
    security group, so only pods in the cluster can reach this component.
  EOT
  type    = list(string)
  default = []
}

variable "allowed_cidrs" {
  description = "Optional extra CIDRs allowed (kept empty by default — prefer SG references)."
  type        = list(string)
  default     = []
}

variable "tags" {
  type    = map(string)
  default = {}
}

locals {
  port_to = coalesce(var.ingress_port_to, var.ingress_port)
}

resource "aws_security_group" "this" {
  name        = var.name
  description = var.description
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, { Name = var.name })
}

# One ingress rule per source security group — i.e. "allow from the EKS pods".
# Using SG references (not CIDRs) means this keeps working even though pods use
# the 100.64.0.0/16 secondary CIDR via VPC CNI custom networking.
resource "aws_vpc_security_group_ingress_rule" "from_sg" {
  for_each = toset(var.source_security_group_ids)

  security_group_id            = aws_security_group.this.id
  referenced_security_group_id = each.value
  from_port                    = var.ingress_port
  to_port                      = local.port_to
  ip_protocol                  = "tcp"
  description                  = "Allow from ${each.value} (EKS pods)"
}

resource "aws_vpc_security_group_ingress_rule" "from_cidr" {
  for_each = toset(var.allowed_cidrs)

  security_group_id = aws_security_group.this.id
  cidr_ipv4         = each.value
  from_port         = var.ingress_port
  to_port           = local.port_to
  ip_protocol       = "tcp"
  description       = "Allow from ${each.value}"
}

output "security_group_id" {
  value = aws_security_group.this.id
}
