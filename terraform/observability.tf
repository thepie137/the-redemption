# Observability runs in SG (the DR region) on purpose: if TH is the
# incident, dashboards + alerting must survive. Both clusters remote_write
# to this Managed Prometheus workspace. Falls back to TH only if DR is off.
module "observability" {
  source    = "./modules/observability"
  providers = { aws = aws.sg }

  count = var.enable_dr ? 1 : 0

  name             = "${var.project}-${var.environment}"
  logs_kms_key_arn = module.kms_sg.key_arns["logs"]
  tags             = local.common_tags
}
