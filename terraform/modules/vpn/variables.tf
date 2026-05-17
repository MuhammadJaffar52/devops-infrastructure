# =========================================================
# ENABLE MODULE
# =========================================================

variable "enabled" {

  description = "Enable or disable VPN module"

  type    = bool
  default = true
}

# =========================================================
# ENVIRONMENT
# =========================================================

variable "environment" {

  description = "Deployment environment (dev/staging/prod)"

  type = string

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}

# =========================================================
# VPC ID
# =========================================================

variable "vpc_id" {

  description = "VPC ID where VPN will be attached"

  type = string

  validation {
    condition     = length(var.vpc_id) > 0
    error_message = "VPC ID cannot be empty."
  }
}

# =========================================================
# VPC CIDR
# =========================================================

variable "vpc_cidr" {

  description = "VPC CIDR block for authorization rules"

  type = string

  validation {
    condition     = length(var.vpc_cidr) > 0
    error_message = "VPC CIDR cannot be empty."
  }
}

# =========================================================
# PRIVATE SUBNETS
# =========================================================

variable "private_subnets" {

  description = "Private subnet IDs for VPN association"

  type = list(string)

  validation {
    condition     = length(var.private_subnets) >= 1
    error_message = "At least one private subnet is required."
  }
}

# =========================================================
# CLIENT CIDR BLOCK
# =========================================================

variable "client_cidr_block" {

  description = "CIDR block for VPN clients"

  type    = string
  default = "172.16.0.0/22"

  validation {
    condition     = can(cidrhost(var.client_cidr_block, 0))
    error_message = "Client CIDR block must be a valid CIDR."
  }
}

# =========================================================
# SERVER CERTIFICATE ARN
# =========================================================

variable "server_certificate_arn" {

  description = "ACM server certificate ARN for VPN"

  type     = string
  default  = null

  validation {
    condition     = var.server_certificate_arn == null || length(var.server_certificate_arn) > 0
    error_message = "Server certificate ARN must be valid or null."
  }
}

# =========================================================
# CLIENT ROOT CERTIFICATE ARN
# =========================================================

variable "client_root_certificate_arn" {

  description = "Root certificate ARN for client authentication"

  type     = string
  default  = null

  validation {
    condition     = var.client_root_certificate_arn == null || length(var.client_root_certificate_arn) > 0
    error_message = "Client root certificate ARN must be valid or null."
  }
}

# =========================================================
# ALLOWED CIDR BLOCKS
# =========================================================

variable "allowed_cidr_blocks" {

  description = "CIDR blocks allowed to connect to VPN"

  type    = list(string)
  default = ["0.0.0.0/0"]
}