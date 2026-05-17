# =========================================================
# PRIVATE SUBNET IDS
# =========================================================

variable "private_subnets" {

  description = "Private subnet IDs for EKS cluster"

  type = list(string)

  validation {

    condition = length(var.private_subnets) >= 2

    error_message = "At least two private subnets are required."
  }
}

# =========================================================
# AWS REGION
# =========================================================

variable "aws_region" {

  description = "AWS region for deployment"

  type = string

  validation {

    condition = length(var.aws_region) > 0

    error_message = "AWS region cannot be empty."
  }
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
# EKS CLUSTER NAME
# =========================================================

variable "cluster_name" {

  description = "EKS cluster name"

  type = string

  validation {

    condition = length(var.cluster_name) > 3

    error_message = "Cluster name is too short."
  }
}

# =========================================================
# NODE GROUP NAME
# =========================================================

variable "node_group_name" {

  description = "EKS managed node group name"

  type = string

  validation {

    condition = length(var.node_group_name) > 3

    error_message = "Node group name is too short."
  }
}

# =========================================================
# INSTANCE TYPES
# =========================================================

variable "instance_types" {

  description = "EKS worker node instance types"

  type = list(string)

  validation {

    condition = length(var.instance_types) > 0

    error_message = "At least one instance type is required."
  }
}

# =========================================================
# NODE SCALING
# =========================================================

variable "desired_size" {

  description = "Desired node count"

  type = number

  validation {

    condition = var.desired_size >= 1

    error_message = "Desired size must be at least 1."
  }
}

variable "min_size" {

  description = "Minimum node count"

  type = number

  validation {

    condition = var.min_size >= 1

    error_message = "Minimum size must be at least 1."
  }
}

variable "max_size" {

  description = "Maximum node count"

  type = number

  validation {

    condition = var.max_size >= var.min_size

    error_message = "Max size must be greater than or equal to min size."
  }
}