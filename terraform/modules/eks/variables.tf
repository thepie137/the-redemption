variable "name" {
  description = "Cluster name / resource prefix, e.g. redemption-prod-th."
  type        = string
}

variable "cluster_version" {
  description = "EKS Kubernetes minor version."
  type        = string
}

variable "vpc_id" { type = string }
variable "private_subnet_ids" { type = list(string) }
variable "public_subnet_ids" { type = list(string) }

variable "secrets_kms_key_arn" {
  description = "KMS key ARN used for EKS secret envelope encryption (from the kms module)."
  type        = string
}

variable "ebs_kms_key_arn" {
  description = "KMS key ARN used to encrypt EKS node EBS volumes."
  type        = string
}

variable "logs_kms_key_arn" {
  description = "KMS key ARN for the cluster CloudWatch log group."
  type        = string
}

variable "system_node_instance_types" { type = list(string) }
variable "system_node_min_size" { type = number }
variable "system_node_max_size" { type = number }

variable "allowed_admin_cidrs" {
  description = "CIDRs allowed to reach the public EKS endpoint. Empty list = private-only endpoint."
  type        = list(string)
  default     = []
}

variable "admin_principal_arns" {
  description = "IAM principal ARNs (roles/users) that get cluster-admin via EKS Access Entries. Typically the SRE/admin SSO role."
  type        = list(string)
  default     = []
}

variable "developer_principal_arns" {
  description = "IAM principal ARNs that get namespaced edit access (AmazonEKSEditPolicy) via Access Entries."
  type        = list(string)
  default     = []
}

variable "developer_namespaces" {
  description = "Namespaces developers are scoped to when developer_principal_arns is set."
  type        = list(string)
  default     = ["redemption"]
}

variable "pod_identity_associations" {
  description = <<-EOT
    Map of association key => { namespace, service_account, role_arn }.
    Creates EKS Pod Identity associations so the named ServiceAccount
    assumes the given IAM role without OIDC/IRSA annotations.
  EOT
  type = map(object({
    namespace       = string
    service_account = string
    role_arn        = string
  }))
  default = {}
}

variable "enable_public_endpoint" {
  description = "Whether the API server has a public endpoint at all. When true, restricted to allowed_admin_cidrs."
  type        = bool
  default     = false
}

variable "tags" { type = map(string) }
