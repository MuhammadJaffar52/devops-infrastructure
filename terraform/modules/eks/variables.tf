# =========================================================

# PRIVATE SUBNETS

# =========================================================

#

# Private subnet IDs used by:

# - EKS cluster

# - worker nodes

#

# Example:

# ["subnet-123", "subnet-456"]

# =========================================================

variable "private_subnets" {

description = "Private subnet IDs for EKS"

type = list(string)
}

# =========================================================

# AWS REGION

# =========================================================

#

# Examples:

# - eu-west-1

# - us-east-1

# - ap-south-1

#

# PHASE 5 IMPROVEMENT:

# Removes hardcoded AWS region dependency.

# =========================================================

variable "aws_region" {

description = "AWS region"

type = string
}

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

# - naming

# - tagging

# - environment isolation

# =========================================================

variable "environment" {

description = "Deployment environment"

type = string
}

# =========================================================

# EKS CLUSTER NAME

# =========================================================

#

# Example:

# dev-eks-cluster

#

# PHASE 5 IMPROVEMENT:

# Removes hardcoded cluster names.

# =========================================================

variable "cluster_name" {

description = "EKS cluster name"

type = string
}

# =========================================================

# NODE GROUP NAME

# =========================================================

#

# Example:

# dev-node-group

# =========================================================

variable "node_group_name" {

description = "EKS node group name"

type = string
}

# =========================================================

# INSTANCE TYPES

# =========================================================

#

# Examples:

# - t3.medium

# - t3.large

# - m5.large

#

# Allows different environments to use

# different instance sizes.

# =========================================================

variable "instance_types" {

description = "EKS worker node instance types"

type = list(string)
}

# =========================================================

# NODE SCALING

# =========================================================

variable "desired_size" {

description = "Desired node count"

type = number
}

variable "min_size" {

description = "Minimum node count"

type = number
}

variable "max_size" {

description = "Maximum node count"

type = number
}
