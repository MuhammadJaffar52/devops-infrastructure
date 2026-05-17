# ============================================================
# GLOBAL LOCALS (HARDENED + PORTABLE)
# ============================================================
#
# PURPOSE:
# Central naming + tagging standard for entire platform.
# ============================================================

locals {

  # ==========================================================
  # AWS METADATA
  # ==========================================================

  aws_account_id = data.aws_caller_identity.current.account_id

  aws_region = data.aws_region.current.name

  # ==========================================================
  # PLATFORM CORE
  # ==========================================================

  project_name = var.project_name

  environment  = var.environment

  domain_name  = var.domain_name

  # ==========================================================
  # NAMING CONVENTIONS
  # ==========================================================

  name_prefix      = "${local.project_name}-${local.environment}"

  eks_cluster_name = "${local.name_prefix}-eks"

  vpc_name         = "${local.name_prefix}-vpc"

  # ==========================================================
  # COMMON TAGS (SAFE + CONSISTENT)
  # ==========================================================

  common_tags = merge(
    {
      Project     = local.project_name
      Environment = local.environment
      Region      = local.aws_region
      ManagedBy   = "Terraform"
      AccountID   = local.aws_account_id
    },
    try(var.common_tags, {})
  )
}