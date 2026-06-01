output "cluster_name" { value = aws_eks_cluster.this.name }
output "cluster_endpoint" { value = aws_eks_cluster.this.endpoint }
output "cluster_certificate_authority_data" { value = aws_eks_cluster.this.certificate_authority[0].data }
output "cluster_security_group_id" { value = aws_security_group.cluster.id }

# The EKS-managed cluster SG that VPC CNI attaches to pod ENIs (and managed
# node ENIs). Data-tier SGs allow ingress from THIS id to permit "connection
# from EKS pods" — works across the 100.64.0.0/16 pod CIDR.
output "cluster_primary_security_group_id" {
  value = aws_eks_cluster.this.vpc_config[0].cluster_security_group_id
}

output "oidc_provider_arn" { value = aws_iam_openid_connect_provider.this.arn }
output "oidc_provider_url" { value = local.oidc_provider_url }

output "node_role_arn" { value = aws_iam_role.node.arn }
output "node_role_name" { value = aws_iam_role.node.name }

output "karpenter_controller_role_arn" { value = aws_iam_role.karpenter_controller.arn }
output "karpenter_interruption_queue" { value = aws_sqs_queue.karpenter_interruption.name }
