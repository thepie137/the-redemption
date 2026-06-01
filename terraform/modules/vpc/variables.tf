variable "name" {
  description = "Resource name prefix (e.g. redemption-prod)."
  type        = string
}

variable "cidr" {
  description = "Primary CIDR block for the VPC. Nodes get 10.x.x.x addresses from here."
  type        = string
}

variable "pod_cidr" {
  description = <<-EOT
    Secondary CIDR for pod ENIs (VPC CNI custom networking). Pods get
    100.x.x.x addresses from here, keeping node and pod address space
    cleanly separated and conserving the 10.x space.
  EOT
  type    = string
  default = "100.64.0.0/16"
}

variable "azs" {
  description = "Availability zones the VPC spans. Three are required for AZ-failure tolerance."
  type        = list(string)
}

variable "cluster_name" {
  description = "EKS cluster name; used in the subnet tags Karpenter and the AWS LBC discover."
  type        = string
}

variable "tags" {
  description = "Tags applied to every VPC resource."
  type        = map(string)
}
