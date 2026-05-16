# =========================================================
# AWS REGION
# =========================================================
#
# Controls deployment region.
#
# Examples:
# - eu-west-1
# - us-east-1
# - ap-south-1
#
# PHASE 5 IMPROVEMENT:
# Removed hardcoded AWS region dependency.
# =========================================================

variable "aws_region" {

  description = "AWS region for infrastructure deployment"

  type = string
}

# =========================================================
# ENVIRONMENT
# =========================================================
#
# Supported:
# - dev
# - staging
# - prod
#
# PHASE 5 IMPROVEMENT:
# Enables multi-environment deployments.
# =========================================================

variable "environment" {

  description = "Deployment environment"

  type = string

  validation {

    condition = contains(
      ["dev", "staging", "prod"],
      var.environment
    )

    error_message =
      "Environment must be dev, staging, or prod."
  }
}

# =========================================================
# DOMAIN NAME
# =========================================================
#
# Base domain for ingress and DNS.
#
# Example:
# example.com
# =========================================================

variable "domain_name" {

  description = "Base domain name"

  type = string
}

# =========================================================
# VPC CIDR
# =========================================================
#
# Example:
# 10.0.0.0/16
#
# PHASE 5 IMPROVEMENT:
# Makes networking reusable across:
# - accounts
# - regions
# - environments
# =========================================================

variable "vpc_cidr" {

  description = "VPC CIDR block"

  type = string
}

# =========================================================
# VPN SERVER CERTIFICATE
# =========================================================

variable "server_certificate_arn" {

  description =
    "ARN of ACM server certificate for AWS Client VPN"

  type = string
}

# =========================================================
# VPN CLIENT ROOT CERTIFICATE
# =========================================================

variable "client_root_certificate_arn" {

  description =
    "ARN of client root certificate for AWS Client VPN"

  type = string
}