variable "name" { type = string }
variable "rate_limit" {
  description = "Requests per 5 minutes per IP before the rate rule blocks."
  type        = number
  default     = 2000
}
variable "tags" { type = map(string) }
