# ============================================================
# AWS REGION
# ============================================================

variable "aws_region" {

  description = "AWS region where infrastructure will be deployed"

  type = string

  validation {
    condition     = length(var.aws_region) > 0
    error_message = "aws_region must not be empty."
  }
}

# ============================================================
# ENVIRONMENT
# ============================================================

variable "environment" {

  description = "Deployment environment name"

  type = string

  validation {
    condition = contains(
      ["dev", "staging", "prod"],
      var.environment
    )

    error_message = "environment must be dev, staging, or prod."
  }
}

# ============================================================
# DOMAIN NAME
# ============================================================

variable "domain_name" {

  description = "Primary domain name for platform ingress"

  type = string

  default = null

  validation {
    condition = var.domain_name == null || can(regex("^[a-zA-Z0-9.-]+$", var.domain_name))
    error_message = "domain_name must be valid or null."
  }
}

# ============================================================
# VPC CIDR
# ============================================================

variable "vpc_cidr" {

  description = "CIDR block for VPC"

  type = string

  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "vpc_cidr must be a valid CIDR block."
  }
}

# ============================================================
# PROJECT NAME
# ============================================================

variable "project_name" {

  description = "Reusable project/platform name"

  type = string

  default = "devops-platform"

  validation {
    condition     = length(var.project_name) > 0
    error_message = "project_name must not be empty."
  }
}

# ============================================================
# COMMON TAGS
# ============================================================

variable "common_tags" {

  description = "Common tags applied to all resources"

  type = map(string)

  default = {
    ManagedBy = "Terraform"
    Platform  = "DevOps"
  }
}