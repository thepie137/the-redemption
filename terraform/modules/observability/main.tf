# Amazon Managed Prometheus + Grafana. Deployed in the DR region (SG) on
# purpose: if the primary region (TH) is the incident, our dashboards and
# alerting must still be up. Both clusters remote_write here with an
# external_label region={th|sg}.
resource "aws_prometheus_workspace" "this" {
  alias = var.name
  tags  = var.tags
}

resource "aws_prometheus_rule_group_namespace" "slo" {
  name         = "slo-rules"
  workspace_id = aws_prometheus_workspace.this.id
  data         = <<-EOT
    groups:
      - name: redemption.slo
        interval: 30s
        rules:
          - record: redemption:request_success_ratio:5m
            expr: |
              sum(rate(http_requests_total{job="redemption",code!~"5.."}[5m]))
              /
              sum(rate(http_requests_total{job="redemption"}[5m]))
          - record: redemption:latency_p99:5m
            expr: |
              histogram_quantile(0.99,
                sum by (le) (rate(http_request_duration_seconds_bucket{job="redemption"}[5m])))
          - alert: RedemptionFastBurn
            expr: |
              (1 - redemption:request_success_ratio:5m) > (14.4 * (1 - 0.9995))
            for: 5m
            labels: { severity: page, slo: redemption-availability }
            annotations:
              summary: "Redemption error budget burning fast"
              runbook: "https://runbooks/redemption/fast-burn"
          - alert: RedemptionLatencyP99High
            expr: redemption:latency_p99:5m > 0.5
            for: 10m
            labels: { severity: page, slo: redemption-latency }
            annotations:
              summary: "p99 latency above 500ms SLO"
              runbook: "https://runbooks/redemption/latency"
  EOT
}

resource "aws_grafana_workspace" "this" {
  name                     = var.name
  account_access_type      = "CURRENT_ACCOUNT"
  authentication_providers = ["AWS_SSO"]
  permission_type          = "SERVICE_MANAGED"
  data_sources             = ["PROMETHEUS", "CLOUDWATCH", "XRAY"]
  tags                     = var.tags
}

resource "aws_cloudwatch_log_group" "app" {
  name              = "/redemption/${var.name}/application"
  retention_in_days = 90
  kms_key_id        = var.logs_kms_key_arn
  tags              = var.tags
}

resource "aws_cloudwatch_log_group" "audit" {
  name              = "/redemption/${var.name}/audit"
  retention_in_days = 365
  kms_key_id        = var.logs_kms_key_arn
  tags              = var.tags
}

output "prometheus_endpoint" { value = aws_prometheus_workspace.this.prometheus_endpoint }
output "grafana_endpoint" { value = aws_grafana_workspace.this.endpoint }
