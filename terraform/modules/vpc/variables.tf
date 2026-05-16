# =========================================================
# ENVIRONMENT
# =========================================================
#
# Examples:
# - dev
# - staging
# - prod
#
# Used for:
# - resource naming
# - tagging
# - portability
# =========================================================

variable "environment" {

  description = "Deployment environment"

  type = string
}

# =========================================================
# VPC CIDR
# =========================================================
#
# Example:
# 10.0.0.0/16
#
# Used for:
# - VPC network
# - subnet generation
# =========================================================

variable "vpc_cidr" {

  description = "VPC CIDR block"

  type = string
}

# =========================================================
# EKS CLUSTER NAME
# =========================================================
#
# Required for:
# Kubernetes subnet tagging
#
# Example:
# dev-devops-eks
# =========================================================

variable "cluster_name" {

  description = "EKS cluster name"

  type = string
}