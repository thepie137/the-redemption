# Account-level detective controls in the primary region. GuardDuty findings
# and Security Hub (CIS / AWS Foundational) feed the SRE PagerDuty rotation.
resource "aws_guardduty_detector" "th" {
  enable                       = true
  finding_publishing_frequency = "FIFTEEN_MINUTES"
  tags                         = local.common_tags
}

resource "aws_securityhub_account" "th" {}

resource "aws_securityhub_standards_subscription" "th_foundational" {
  depends_on    = [aws_securityhub_account.th]
  standards_arn = "arn:aws:securityhub:${var.th_region}::standards/aws-foundational-security-best-practices/v/1.0.0"
}
