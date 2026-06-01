module "eks_th" {
  source = "./modules/eks"

  name            = local.name_th
  cluster_version = var.eks_th.cluster_version

  vpc_id             = module.vpc_th.vpc_id
  private_subnet_ids = module.vpc_th.private_subnet_ids
  public_subnet_ids  = module.vpc_th.public_subnet_ids

  secrets_kms_key_arn = module.kms_th.key_arns["eks"]
  ebs_kms_key_arn     = module.kms_th.key_arns["ebs"]
  logs_kms_key_arn    = module.kms_th.key_arns["logs"]

  system_node_instance_types = var.eks_th.system_node_instance_types
  system_node_min_size       = var.eks_th.system_node_min_size
  system_node_max_size       = var.eks_th.system_node_max_size

  enable_public_endpoint = var.eks_th.enable_public_endpoint
  allowed_admin_cidrs    = var.eks_th.allowed_admin_cidrs

  admin_principal_arns     = var.admin_principal_arns
  developer_principal_arns = var.developer_principal_arns
  developer_namespaces     = ["redemption"]

  # App gets its AWS identity via Pod Identity (role created in iam-th.tf,
  # trust on pods.eks.amazonaws.com — no OIDC dependency, so no cycle).
  pod_identity_associations = {
    app = {
      namespace       = "redemption"
      service_account = "redemption"
      role_arn        = aws_iam_role.app_pod_identity_th.arn
    }
  }

  tags = local.common_tags
}
