variable "vpc_name" {
  description = "Name tag of the VPC"
  type        = string
}

variable "subnet_names" {
  description = "List of 3 subnet names"
  type        = list(string)

  validation {
    condition     = length(var.subnet_names) == 3
    error_message = "Exactly 3 subnet names must be provided."
  }
}

variable "endpoint_name" {
  description = "Name of the VPC endpoint"
  type        = string
}

variable "endpoint_service" {
  description = "AWS service (e.g. execute-api, kms, logs)"
  type        = string
  default     = "execute-api"
}

variable "private_dns_enabled" {
  description = "Enable private DNS"
  type        = bool
  default     = false
}

variable "security_group_name" {
  description = "Security group name"
  type        = string
}

variable "ingress_rules" {
  description = "List of ingress rules"
  type = list(object({
    description = string
    cidr        = string
  }))

  validation {
    condition     = length(var.ingress_rules) == 2
    error_message = "Exactly 2 ingress rules required."
  }
}

variable "endpoint_policy" {
  description = "Custom VPC endpoint policy (JSON). If null, default allow-all is used."
  type        = string
  default     = null
}

variable "tags" {
  description = "Common tags"
  type        = map(string)
  default     = {}
}