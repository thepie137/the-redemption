# ===========================================================================
# SG IAM — mirror of iam-th.tf for the DR cluster. count-gated on enable_dr.
# ===========================================================================

resource "aws_iam_role" "app_pod_identity_sg" {
  count = var.enable_dr ? 1 : 0

  name               = "${local.name_sg}-app"
  assume_role_policy = data.aws_iam_policy_document.pod_identity_assume.json
  tags               = local.common_tags
}

data "aws_iam_policy_document" "app_sg" {
  count = var.enable_dr ? 1 : 0

  statement {
    sid       = "ReadSecrets"
    effect    = "Allow"
    actions   = ["secretsmanager:GetSecretValue", "secretsmanager:DescribeSecret"]
    resources = ["arn:aws:secretsmanager:${var.sg_region}:*:secret:redemption/*"]
  }
  statement {
    sid       = "DecryptSecrets"
    effect    = "Allow"
    actions   = ["kms:Decrypt", "kms:DescribeKey"]
    resources = [module.kms_sg.key_arns["secrets"], module.kms_sg.key_arns["rds"]]
  }
  statement {
    sid       = "AppBucketObjects"
    effect    = "Allow"
    actions   = ["s3:GetObject", "s3:PutObject", "s3:DeleteObject"]
    resources = ["${module.s3_sg[0].bucket_arn}/*"]
  }
  statement {
    sid       = "AppBucketList"
    effect    = "Allow"
    actions   = ["s3:ListBucket"]
    resources = [module.s3_sg[0].bucket_arn]
  }
  statement {
    sid       = "S3Kms"
    effect    = "Allow"
    actions   = ["kms:Decrypt", "kms:GenerateDataKey"]
    resources = [module.kms_sg.key_arns["s3"]]
  }
}

resource "aws_iam_role_policy" "app_sg" {
  count = var.enable_dr ? 1 : 0

  name   = "${local.name_sg}-app"
  role   = aws_iam_role.app_pod_identity_sg[0].id
  policy = data.aws_iam_policy_document.app_sg[0].json
}

# ---- External Secrets Operator (IRSA) ----
data "aws_iam_policy_document" "external_secrets_sg" {
  count = var.enable_dr ? 1 : 0

  statement {
    effect    = "Allow"
    actions   = ["secretsmanager:GetSecretValue", "secretsmanager:DescribeSecret", "secretsmanager:ListSecretVersionIds"]
    resources = ["arn:aws:secretsmanager:${var.sg_region}:*:secret:redemption/*"]
  }
  statement {
    effect    = "Allow"
    actions   = ["kms:Decrypt"]
    resources = [module.kms_sg.key_arns["secrets"]]
  }
}

module "irsa_external_secrets_sg" {
  source    = "./modules/irsa"
  providers = { aws = aws.sg }

  count = var.enable_dr ? 1 : 0

  name              = "${local.name_sg}-external-secrets"
  oidc_provider_arn = module.eks_sg[0].oidc_provider_arn
  oidc_provider_url = module.eks_sg[0].oidc_provider_url
  namespace         = "external-secrets"
  service_account   = "external-secrets"
  policy_json       = data.aws_iam_policy_document.external_secrets_sg[0].json
  tags              = local.common_tags
}

# ---- AWS Load Balancer Controller (IRSA) ----
module "irsa_lbc_sg" {
  source    = "./modules/irsa"
  providers = { aws = aws.sg }

  count = var.enable_dr ? 1 : 0

  name              = "${local.name_sg}-aws-lbc"
  oidc_provider_arn = module.eks_sg[0].oidc_provider_arn
  oidc_provider_url = module.eks_sg[0].oidc_provider_url
  namespace         = "kube-system"
  service_account   = "aws-load-balancer-controller"
  policy_json       = data.aws_iam_policy_document.lbc_th.json # same action set, region-agnostic
  tags              = local.common_tags
}
