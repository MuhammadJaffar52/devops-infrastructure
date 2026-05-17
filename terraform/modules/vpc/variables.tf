# ============================================================
# VPC MODULE VARIABLES
# ============================================================
#
# PURPOSE:
# Reusable VPC module variables.
#
# FEATURES:
# - Multi-account compatible
# - Multi-region compatible
# - Environment-aware
# - Production-grade validation
# - Dynamic subnet architecture
#
# ============================================================

# ============================================================
# ENVIRONMENT
# ============================================================

variable "environment" {

  description = "Deployment environment"

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
# PROJECT NAME
# ============================================================

variable "project_name" {

  description = "Reusable platform project name"

  type = string

  default = "devops-platform"

  validation {

    condition = length(var.project_name) > 0

    error_message = "project_name must not be empty."
  }
}

# ============================================================
# AWS REGION
# ============================================================

variable "aws_region" {

  description = "AWS region"

  type = string

  validation {

    condition = length(var.aws_region) > 0

    error_message = "aws_region must not be empty."
  }
}

# ============================================================
# VPC CIDR
# ============================================================

variable "vpc_cidr" {

  description = "Primary VPC CIDR block"

  type = string

  validation {

    condition = can(cidrhost(var.vpc_cidr, 0))

    error_message = "vpc_cidr must be a valid CIDR block."
  }
}

# ============================================================
# EKS CLUSTER NAME
# ============================================================

variable "cluster_name" {

  description = "EKS cluster name"

  type = string

  validation {

    condition = length(var.cluster_name) > 0

    error_message = "cluster_name must not be empty."
  }
}

# ============================================================
# AVAILABILITY ZONES
# ============================================================

variable "availability_zones" {

  description = "List of AWS availability zones"

  type = list(string)

  validation {

    condition = length(var.availability_zones) >= 2

    error_message = "At least 2 availability zones are required."
  }
}

# ============================================================
# PUBLIC SUBNET CIDRS
# ============================================================

variable "public_subnet_cidrs" {

  description = "Public subnet CIDR blocks"

  type = list(string)

  validation {

    condition = length(var.public_subnet_cidrs) >= 2

    error_message = "At least 2 public subnets are required."
  }
}

# ============================================================
# PRIVATE SUBNET CIDRS
# ============================================================

variable "private_subnet_cidrs" {

  description = "Private subnet CIDR blocks"

  type = list(string)

  validation {

    condition = length(var.private_subnet_cidrs) >= 2

    error_message = "At least 2 private subnets are required."
  }
}

# ============================================================
# COMMON TAGS
# ============================================================

variable "common_tags" {

  description = "Common resource tags"

  type = map(string)

  default = {}
}