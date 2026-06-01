variable "name" {
  description = "Role name, e.g. redemption-prod-th-external-secrets."
  type        = string
}

variable "oidc_provider_arn" {
  description = "EKS cluster OIDC provider ARN."
  type        = string
}

variable "oidc_provider_url" {
  description = "EKS cluster OIDC provider URL without the https:// prefix."
  type        = string
}

variable "namespace" {
  description = "Kubernetes namespace of the ServiceAccount."
  type        = string
}

variable "service_account" {
  description = "ServiceAccount name to bind."
  type        = string
}

variable "policy_json" {
  description = "IAM policy document (JSON) attached inline to the role."
  type        = string
}

variable "tags" {
  type    = map(string)
  default = {}
}
