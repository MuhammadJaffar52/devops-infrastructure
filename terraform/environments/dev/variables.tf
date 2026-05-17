# =========================================================
# AWS REGION
# =========================================================

variable "aws_region" {

  description = "AWS region for infrastructure deployment"

  type = string
}

# =========================================================
# ENVIRONMENT
# =========================================================

variable "environment" {

  description = "Deployment environment"

  type = string

  validation {
    condition = contains(
      ["dev", "staging", "prod"],
      var.environment
    )

    error_message = "Environment must be dev, staging, or prod."
  }
}

# =========================================================
# DOMAIN NAME
# =========================================================

variable "domain_name" {

  description = "Base domain name for ingress"

  type = string

  default = null

  validation {
    condition = var.domain_name == null || can(regex("^[a-zA-Z0-9.-]+$", var.domain_name))
    error_message = "Invalid domain name format."
  }
}

# =========================================================
# VPC CIDR
# =========================================================

variable "vpc_cidr" {

  description = "VPC CIDR block"

  type = string
}

# =========================================================
# VPN SERVER CERTIFICATE (OPTIONAL SAFE MODE)
# =========================================================

variable "server_certificate_arn" {

  description = "ACM server certificate ARN for Client VPN"

  type = string

  default = null
}

# =========================================================
# VPN CLIENT ROOT CERTIFICATE (OPTIONAL SAFE MODE)
# =========================================================

variable "client_root_certificate_arn" {

  description = "Client root certificate ARN for VPN authentication"

  type = string

  default = null
}