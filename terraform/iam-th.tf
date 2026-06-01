# ===========================================================================
# TH IAM — application Pod Identity role + controller IRSA roles
# ===========================================================================

# ---- App Pod Identity role (trust = pods.eks.amazonaws.com, no OIDC) ----
data "aws_iam_policy_document" "pod_identity_assume" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole", "sts:TagSession"]
    principals {
      type        = "Service"
      identifiers = ["pods.eks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "app_pod_identity_th" {
  name               = "${local.name_th}-app"
  assume_role_policy = data.aws_iam_policy_document.pod_identity_assume.json
  tags               = local.common_tags
}

# Least privilege: read only the app's own secrets + the RDS-managed master
# secret, decrypt with the secrets KMS key, and read/write the app S3 bucket.
data "aws_iam_policy_document" "app_th" {
  statement {
    sid       = "ReadSecrets"
    effect    = "Allow"
    actions   = ["secretsmanager:GetSecretValue", "secretsmanager:DescribeSecret"]
    resources = compact(concat(module.secrets_th.secret_arn_list, [module.rds_th.master_user_secret_arn]))
  }
  statement {
    sid       = "DecryptSecrets"
    effect    = "Allow"
    actions   = ["kms:Decrypt", "kms:DescribeKey"]
    resources = [module.kms_th.key_arns["secrets"], module.kms_th.key_arns["rds"]]
  }
  statement {
    sid       = "AppBucketObjects"
    effect    = "Allow"
    actions   = ["s3:GetObject", "s3:PutObject", "s3:DeleteObject"]
    resources = ["${module.s3_th.bucket_arn}/*"]
  }
  statement {
    sid       = "AppBucketList"
    effect    = "Allow"
    actions   = ["s3:ListBucket"]
    resources = [module.s3_th.bucket_arn]
  }
  statement {
    sid       = "S3Kms"
    effect    = "Allow"
    actions   = ["kms:Decrypt", "kms:GenerateDataKey"]
    resources = [module.kms_th.key_arns["s3"]]
  }
}

resource "aws_iam_role_policy" "app_th" {
  name   = "${local.name_th}-app"
  role   = aws_iam_role.app_pod_identity_th.id
  policy = data.aws_iam_policy_document.app_th.json
}

# ---- External Secrets Operator (IRSA) ----
data "aws_iam_policy_document" "external_secrets_th" {
  statement {
    effect    = "Allow"
    actions   = ["secretsmanager:GetSecretValue", "secretsmanager:DescribeSecret", "secretsmanager:ListSecretVersionIds"]
    resources = ["arn:aws:secretsmanager:${var.th_region}:*:secret:redemption/*"]
  }
  statement {
    effect    = "Allow"
    actions   = ["kms:Decrypt"]
    resources = [module.kms_th.key_arns["secrets"]]
  }
}

module "irsa_external_secrets_th" {
  source = "./modules/irsa"

  name              = "${local.name_th}-external-secrets"
  oidc_provider_arn = module.eks_th.oidc_provider_arn
  oidc_provider_url = module.eks_th.oidc_provider_url
  namespace         = "external-secrets"
  service_account   = "external-secrets"
  policy_json       = data.aws_iam_policy_document.external_secrets_th.json
  tags              = local.common_tags
}

# ---- AWS Load Balancer Controller (IRSA) ----
# Policy is the upstream canonical document, abbreviated to the actions the
# controller actually invokes for an internet-facing ALB + target groups.
data "aws_iam_policy_document" "lbc_th" {
  statement {
    effect = "Allow"
    actions = [
      "elasticloadbalancing:*",
      "ec2:DescribeVpcs",
      "ec2:DescribeSubnets",
      "ec2:DescribeSecurityGroups",
      "ec2:DescribeInstances",
      "ec2:DescribeNetworkInterfaces",
      "ec2:CreateSecurityGroup",
      "ec2:CreateTags",
      "ec2:AuthorizeSecurityGroupIngress",
      "ec2:RevokeSecurityGroupIngress",
      "acm:ListCertificates",
      "acm:DescribeCertificate",
      "wafv2:GetWebACL",
      "wafv2:AssociateWebACL",
      "wafv2:DisassociateWebACL",
      "shield:GetSubscriptionState",
    ]
    resources = ["*"]
  }
}

module "irsa_lbc_th" {
  source = "./modules/irsa"

  name              = "${local.name_th}-aws-lbc"
  oidc_provider_arn = module.eks_th.oidc_provider_arn
  oidc_provider_url = module.eks_th.oidc_provider_url
  namespace         = "kube-system"
  service_account   = "aws-load-balancer-controller"
  policy_json       = data.aws_iam_policy_document.lbc_th.json
  tags              = local.common_tags
}
