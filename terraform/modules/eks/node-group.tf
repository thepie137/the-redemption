# System node group: only runs cluster addons + Karpenter. App pods are
# scheduled by Karpenter onto right-sized, spot-friendly nodes per workload.
resource "aws_eks_node_group" "system" {
  cluster_name    = aws_eks_cluster.this.name
  node_group_name = "${var.name}-system"
  node_role_arn   = aws_iam_role.node.arn
  subnet_ids      = var.private_subnet_ids
  instance_types  = var.system_node_instance_types
  capacity_type   = "ON_DEMAND"

  scaling_config {
    min_size     = var.system_node_min_size
    desired_size = var.system_node_min_size
    max_size     = var.system_node_max_size
  }

  update_config { max_unavailable_percentage = 33 }

  # Tainted so application workloads only land here if they explicitly
  # tolerate it. Karpenter, CoreDNS and the load balancer controller do.
  taint {
    key    = "CriticalAddonsOnly"
    value  = "true"
    effect = "NO_SCHEDULE"
  }

  labels = {
    role = "system"
  }

  tags = merge(var.tags, {
    "karpenter.sh/discovery" = aws_eks_cluster.this.name
  })

  lifecycle {
    ignore_changes = [scaling_config[0].desired_size]
  }
}
