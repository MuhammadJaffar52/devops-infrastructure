# ============================================================
# GLOBAL AWS PROVIDER (HARDENED FOUNDATION LAYER)
# ============================================================
#
# PURPOSE:
# Central AWS provider for global Terraform layer.
#
# FEATURES:
# - Multi-environment support
# - Central tagging strategy
# - IRSA-compatible architecture
# - Production-ready defaults
# ============================================================

provider "aws" {

  region = var.aws_region

  default_tags {

    tags = {
      Project     = local.project_name
      Environment = local.environment
      ManagedBy   = "Terraform"
      Layer       = "global"
    }
  }
}