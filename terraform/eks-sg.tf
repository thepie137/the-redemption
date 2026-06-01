module "eks_sg" {
  source    = "./modules/eks"
  providers = { aws = aws.sg }

  count = var.enable_dr ? 1 : 0

  name            = local.name_sg
  cluster_version = var.eks_sg.cluster_version

  vpc_id             = module.vpc_sg.vpc_id
  private_subnet_ids = module.vpc_sg.private_subnet_ids
  public_subnet_ids  = module.vpc_sg.public_subnet_ids

  secrets_kms_key_arn = module.kms_sg.key_arns["eks"]
  ebs_kms_key_arn     = module.kms_sg.key_arns["ebs"]
  logs_kms_key_arn    = module.kms_sg.key_arns["logs"]

  system_node_instance_types = var.eks_sg.system_node_instance_types
  system_node_min_size       = var.eks_sg.system_node_min_size
  system_node_max_size       = var.eks_sg.system_node_max_size

  enable_public_endpoint = var.eks_sg.enable_public_endpoint
  allowed_admin_cidrs    = var.eks_sg.allowed_admin_cidrs

  admin_principal_arns     = var.admin_principal_arns
  developer_principal_arns = var.developer_principal_arns
  developer_namespaces     = ["redemption"]

  pod_identity_associations = {
    app = {
      namespace       = "redemption"
      service_account = "redemption"
      role_arn        = aws_iam_role.app_pod_identity_sg[0].arn
    }
  }

  tags = local.common_tags
}
