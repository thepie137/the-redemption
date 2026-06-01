resource "aws_guardduty_detector" "sg" {
  provider = aws.sg
  count    = var.enable_dr ? 1 : 0

  enable                       = true
  finding_publishing_frequency = "FIFTEEN_MINUTES"
  tags                         = local.common_tags
}

resource "aws_securityhub_account" "sg" {
  provider = aws.sg
  count    = var.enable_dr ? 1 : 0
}

resource "aws_securityhub_standards_subscription" "sg_foundational" {
  provider      = aws.sg
  count         = var.enable_dr ? 1 : 0
  depends_on    = [aws_securityhub_account.sg]
  standards_arn = "arn:aws:securityhub:${var.sg_region}::standards/aws-foundational-security-best-practices/v/1.0.0"
}
