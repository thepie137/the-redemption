# EKS Pod Identity associations. Preferred over IRSA annotations for new
# workloads: no OIDC trust-policy editing, the binding is a first-class AWS
# resource, and the same IAM role can be reused across clusters/regions.
#
# The IAM roles themselves are minted by the `irsa` module at the root and
# passed in here; this module just creates the namespace/SA → role binding.
resource "aws_eks_pod_identity_association" "this" {
  for_each = var.pod_identity_associations

  cluster_name    = aws_eks_cluster.this.name
  namespace       = each.value.namespace
  service_account = each.value.service_account
  role_arn        = each.value.role_arn

  tags = merge(var.tags, { Association = each.key })

  depends_on = [aws_eks_addon.pod_identity_agent]
}
