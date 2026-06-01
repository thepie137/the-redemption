# ---- EKS ----
output "th_cluster_name" {
  value       = module.eks_th.cluster_name
  description = "Primary EKS cluster (Bangkok). Use with: aws eks update-kubeconfig --region ap-southeast-7"
}

output "sg_cluster_name" {
  value       = var.enable_dr ? module.eks_sg[0].cluster_name : null
  description = "DR EKS cluster (Singapore)."
}

output "th_oidc_provider_arn" { value = module.eks_th.oidc_provider_arn }

# Pod networking — feed these into kubernetes/networking/eniconfig.yaml so the
# VPC CNI assigns pods 100.x addresses from the pod subnets, per AZ.
output "th_pod_subnet_ids_by_az" { value = module.vpc_th.pod_subnet_ids_by_az }
output "th_cluster_pod_security_group_id" { value = module.eks_th.cluster_primary_security_group_id }
output "sg_pod_subnet_ids_by_az" { value = var.enable_dr ? module.vpc_sg.pod_subnet_ids_by_az : {} }
output "sg_cluster_pod_security_group_id" { value = var.enable_dr ? module.eks_sg[0].cluster_primary_security_group_id : null }

# ---- IAM / IRSA / Pod Identity ----
output "app_pod_identity_role_arn_th" { value = aws_iam_role.app_pod_identity_th.arn }
output "external_secrets_role_arn_th" { value = module.irsa_external_secrets_th.role_arn }
output "lbc_role_arn_th" { value = module.irsa_lbc_th.role_arn }

# ---- Data tier (regional endpoints; the app uses the Global DNS names) ----
output "rds_th_address" { value = module.rds_th.address }
output "rds_th_master_secret_arn" { value = module.rds_th.master_user_secret_arn }
output "docdb_th_endpoint" { value = module.docdb_th.endpoint }
output "redis_th_endpoint" { value = module.redis_th.configuration_endpoint }
output "kafka_th_brokers" { value = module.kafka_th.bootstrap_brokers_sasl_iam }
output "s3_th_bucket" { value = module.s3_th.bucket }
output "ecr_repository_url" { value = module.ecr_th.repository_url }

# ---- WAF (associate via Ingress annotation) ----
output "waf_th_acl_arn" { value = module.waf_th.web_acl_arn }
output "waf_sg_acl_arn" { value = var.enable_dr ? module.waf_sg[0].web_acl_arn : null }

# ---- Observability ----
output "prometheus_endpoint" {
  value = var.enable_dr ? module.observability[0].prometheus_endpoint : null
}
output "grafana_endpoint" {
  value = var.enable_dr ? module.observability[0].grafana_endpoint : null
}

# ---- Global DNS ----
output "app_hostname" { value = var.dns.app_hostname }
output "data_tier_hostnames" {
  value = var.enable_dr ? {
    db      = local.h_db
    mongo   = local.h_mongo
    cache   = local.h_cache
    objects = local.h_object
  } : {}
}
