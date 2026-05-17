# ============================================================
# GLOBAL DATA SOURCES (HARDENED)
# ============================================================
#
# PURPOSE:
# Centralized AWS metadata for global infrastructure layer.
#
# USED FOR:
# - IAM roles (account ID)
# - region consistency
# - multi-AZ subnet design
# - IRSA / EKS integration
# ============================================================

# ============================================================
# AWS ACCOUNT ID
# ============================================================

data "aws_caller_identity" "current" {}

# ============================================================
# AWS REGION
# ============================================================

data "aws_region" "current" {}

# ============================================================
# AVAILABILITY ZONES
# ============================================================

data "aws_availability_zones" "available" {

  state = "available"
}