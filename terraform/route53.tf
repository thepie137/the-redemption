# ===========================================================================
# Global DNS — one hostname per service, region-failover routed.
#
# A single Route 53 health check on the TH ALB drives every record: when TH
# is unhealthy, the app and all data-tier hostnames flip to SG together
# (active-standby region failover).
#
#   <app_hostname>          → ALB            (A alias)
#   db.<zone>               → RDS writer      (CNAME)
#   mongo.<zone>            → DocumentDB       (CNAME)
#   cache.<zone>            → ElastiCache      (CNAME)
#   objects.<zone>          → S3 MRAP          (CNAME, no failover needed)
#
# Records are gated on `enable_failover`, which requires the ALB DNS names
# (var.alb) — populated on the second apply once the Ingress exists.
# Kafka is intentionally not DNS-routed (bootstrap is a broker list, swapped
# via a Kubernetes ConfigMap on failover).
# ===========================================================================

locals {
  enable_failover = var.enable_dr && var.alb.th_dns != "" && var.alb.sg_dns != ""

  h_db     = "db.${var.dns.zone_name}"
  h_mongo  = "mongo.${var.dns.zone_name}"
  h_cache  = "cache.${var.dns.zone_name}"
  h_object = "objects.${var.dns.zone_name}"
}

data "aws_route53_zone" "this" {
  count        = var.enable_dr ? 1 : 0
  name         = var.dns.zone_name
  private_zone = false
}

resource "aws_route53_health_check" "th_primary" {
  count = local.enable_failover ? 1 : 0

  fqdn              = var.alb.th_dns
  port              = 443
  type              = "HTTPS"
  resource_path     = "/healthz/ready"
  failure_threshold = 3
  request_interval  = 10
  measure_latency   = true
  regions           = ["us-east-1", "eu-west-1", "ap-northeast-1"]

  tags = merge(local.common_tags, { Name = "${local.name_th}-primary" })
}

# ---- App (ALB alias) ----
resource "aws_route53_record" "app_th" {
  count          = local.enable_failover ? 1 : 0
  zone_id        = data.aws_route53_zone.this[0].zone_id
  name           = var.dns.app_hostname
  type           = "A"
  set_identifier = "primary-th"
  failover_routing_policy { type = "PRIMARY" }
  alias {
    name                   = var.alb.th_dns
    zone_id                = var.alb.th_zone_id
    evaluate_target_health = true
  }
  health_check_id = aws_route53_health_check.th_primary[0].id
}

resource "aws_route53_record" "app_sg" {
  count          = local.enable_failover ? 1 : 0
  zone_id        = data.aws_route53_zone.this[0].zone_id
  name           = var.dns.app_hostname
  type           = "A"
  set_identifier = "secondary-sg"
  failover_routing_policy { type = "SECONDARY" }
  alias {
    name                   = var.alb.sg_dns
    zone_id                = var.alb.sg_zone_id
    evaluate_target_health = true
  }
}

# ---- Data tier (CNAME failover) ----
locals {
  data_failover = local.enable_failover ? {
    db    = { host = local.h_db, th = module.rds_th.address, sg = module.rds_sg[0].address }
    mongo = { host = local.h_mongo, th = module.docdb_th.endpoint, sg = module.docdb_sg[0].endpoint }
    cache = { host = local.h_cache, th = module.redis_th.configuration_endpoint, sg = module.redis_sg[0].configuration_endpoint }
  } : {}
}

resource "aws_route53_record" "data_primary" {
  for_each = local.data_failover

  zone_id        = data.aws_route53_zone.this[0].zone_id
  name           = each.value.host
  type           = "CNAME"
  ttl            = 30
  set_identifier = "primary-th"
  failover_routing_policy { type = "PRIMARY" }
  records         = [each.value.th]
  health_check_id = aws_route53_health_check.th_primary[0].id
}

resource "aws_route53_record" "data_secondary" {
  for_each = local.data_failover

  zone_id        = data.aws_route53_zone.this[0].zone_id
  name           = each.value.host
  type           = "CNAME"
  ttl            = 30
  set_identifier = "secondary-sg"
  failover_routing_policy { type = "SECONDARY" }
  records        = [each.value.sg]
}

# ---- S3 objects via Multi-Region Access Point (no failover record) ----
resource "aws_route53_record" "objects" {
  count = var.enable_dr ? 1 : 0

  zone_id = data.aws_route53_zone.this[0].zone_id
  name    = local.h_object
  type    = "CNAME"
  ttl     = 300
  records = ["${aws_s3control_multi_region_access_point.objects[0].alias}.accesspoint.s3-global.amazonaws.com"]
}
