# ---------------------------------------------------------------------------
# EKS Access Entries — the modern, IAM-native authz path (no aws-auth CM).
#
#   admins      → AmazonEKSClusterAdminPolicy (cluster-wide)
#   developers  → AmazonEKSEditPolicy, scoped to developer_namespaces
#
# Admins additionally have SSM session access to nodes via the node role's
# AmazonSSMManagedInstanceCore attachment (iam.tf) — break-glass onto a host
# with full session logging, no SSH key, no inbound port.
# ---------------------------------------------------------------------------

resource "aws_eks_access_entry" "admin" {
  for_each = toset(var.admin_principal_arns)

  cluster_name  = aws_eks_cluster.this.name
  principal_arn = each.value
  type          = "STANDARD"
  tags          = var.tags
}

resource "aws_eks_access_policy_association" "admin" {
  for_each = toset(var.admin_principal_arns)

  cluster_name  = aws_eks_cluster.this.name
  principal_arn = each.value
  policy_arn    = "arn:${data.aws_partition.current.partition}:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"

  access_scope { type = "cluster" }

  depends_on = [aws_eks_access_entry.admin]
}

resource "aws_eks_access_entry" "developer" {
  for_each = toset(var.developer_principal_arns)

  cluster_name  = aws_eks_cluster.this.name
  principal_arn = each.value
  type          = "STANDARD"
  tags          = var.tags
}

resource "aws_eks_access_policy_association" "developer" {
  for_each = toset(var.developer_principal_arns)

  cluster_name  = aws_eks_cluster.this.name
  principal_arn = each.value
  policy_arn    = "arn:${data.aws_partition.current.partition}:eks::aws:cluster-access-policy/AmazonEKSEditPolicy"

  access_scope {
    type       = "namespace"
    namespaces = var.developer_namespaces
  }

  depends_on = [aws_eks_access_entry.developer]
}
