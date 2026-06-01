module "s3_th" {
  source = "./modules/s3"

  bucket_name = var.s3_th.bucket_name
  kms_key_arn = module.kms_th.key_arns["s3"]
  tags        = local.common_tags
}

# ---------------------------------------------------------------------------
# Cross-Region Replication: TH bucket → SG bucket, with Replication Time
# Control (15-minute SLA). Wired here (not in the module) because it needs
# both bucket ARNs and the SG KMS key.
# ---------------------------------------------------------------------------
data "aws_iam_policy_document" "s3_replication_assume" {
  count = var.enable_dr ? 1 : 0
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["s3.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "s3_replication" {
  count              = var.enable_dr ? 1 : 0
  name               = "${local.name_th}-s3-replication"
  assume_role_policy = data.aws_iam_policy_document.s3_replication_assume[0].json
  tags               = local.common_tags
}

data "aws_iam_policy_document" "s3_replication" {
  count = var.enable_dr ? 1 : 0

  statement {
    effect    = "Allow"
    actions   = ["s3:GetReplicationConfiguration", "s3:ListBucket"]
    resources = [module.s3_th.bucket_arn]
  }
  statement {
    effect    = "Allow"
    actions   = ["s3:GetObjectVersionForReplication", "s3:GetObjectVersionAcl", "s3:GetObjectVersionTagging"]
    resources = ["${module.s3_th.bucket_arn}/*"]
  }
  statement {
    effect    = "Allow"
    actions   = ["s3:ReplicateObject", "s3:ReplicateDelete", "s3:ReplicateTags"]
    resources = ["${module.s3_sg[0].bucket_arn}/*"]
  }
  statement {
    effect    = "Allow"
    actions   = ["kms:Decrypt"]
    resources = [module.kms_th.key_arns["s3"]]
  }
  statement {
    effect    = "Allow"
    actions   = ["kms:Encrypt"]
    resources = [module.kms_sg.key_arns["s3"]]
  }
}

resource "aws_iam_role_policy" "s3_replication" {
  count  = var.enable_dr ? 1 : 0
  name   = "${local.name_th}-s3-replication"
  role   = aws_iam_role.s3_replication[0].id
  policy = data.aws_iam_policy_document.s3_replication[0].json
}

resource "aws_s3_bucket_replication_configuration" "th_to_sg" {
  count = var.enable_dr ? 1 : 0

  role   = aws_iam_role.s3_replication[0].arn
  bucket = module.s3_th.bucket

  rule {
    id     = "replicate-all"
    status = "Enabled"
    filter {}
    delete_marker_replication { status = "Enabled" }

    destination {
      bucket        = module.s3_sg[0].bucket_arn
      storage_class = "STANDARD"
      encryption_configuration { replica_kms_key_id = module.kms_sg.key_arns["s3"] }
      replication_time {
        status = "Enabled"
        time { minutes = 15 }
      }
      metrics {
        status = "Enabled"
        event_threshold { minutes = 15 }
      }
    }
  }
}

# Multi-Region Access Point: one global hostname (objects.<zone>) that routes
# each request to the closest healthy bucket — no DNS flip on failover.
resource "aws_s3control_multi_region_access_point" "objects" {
  count = var.enable_dr ? 1 : 0

  details {
    name = "${var.project}-${var.environment}-objects"
    region { bucket = module.s3_th.bucket }
    region { bucket = module.s3_sg[0].bucket }
  }
}
