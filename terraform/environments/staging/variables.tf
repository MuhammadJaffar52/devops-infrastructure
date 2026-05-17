# =========================================================
# AWS REGION
# =========================================================

variable "aws_region" {
  description = "AWS region for infrastructure deployment"
  type        = string
}

# =========================================================
# ENVIRONMENT
# =========================================================

variable "environment" {
  description = "Deployment environment"
  type        = string

  validation {
    condition = contains(
      ["staging"],
      var.environment
    )

    error_message = "This config is only for staging environment."
  }
}

# =========================================================
# VPC CIDR
# =========================================================

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
}

# =========================================================
# DOMAIN NAME
# =========================================================

variable "domain_name" {
  description = "Base domain name for staging ingress"
  type        = string
  default     = null
}

# =========================================================
# VPN SERVER CERTIFICATE (OPTIONAL FOR STAGING SAFETY)
# =========================================================

variable "server_certificate_arn" {
  description = "ACM server certificate ARN for Client VPN"
  type        = string
  default     = null
}

# =========================================================
# VPN CLIENT ROOT CERTIFICATE (OPTIONAL FOR STAGING SAFETY)
# =========================================================

variable "client_root_certificate_arn" {
  description = "Client root certificate ARN for VPN authentication"
  type        = string
  default     = null
}