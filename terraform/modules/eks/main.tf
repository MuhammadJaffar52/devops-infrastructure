# =========================================================
# AWS REGION
# =========================================================

variable "aws_region" {

  description = "AWS region"

  type = string
}

# =========================================================
# ENVIRONMENT
# =========================================================

variable "environment" {

  description = "Deployment environment"

  type = string
}

# =========================================================
# PRIVATE SUBNETS
# =========================================================

variable "private_subnets" {

  description = "Private subnet IDs"

  type = list(string)
}

# =========================================================
# NODE INSTANCE TYPE
# =========================================================

variable "node_instance_type" {

  description = "EKS worker node instance type"

  type = string
}

# =========================================================
# NODE DESIRED SIZE
# =========================================================

variable "node_desired_size" {

  description = "Desired number of worker nodes"

  type = number
}

# =========================================================
# NODE MAX SIZE
# =========================================================

variable "node_max_size" {

  description = "Maximum number of worker nodes"

  type = number
}

# =========================================================
# NODE MIN SIZE
# =========================================================

variable "node_min_size" {

  description = "Minimum number of worker nodes"

  type = number
}