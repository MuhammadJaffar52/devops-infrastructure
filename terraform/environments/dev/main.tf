# =========================================================
# AWS PROVIDER
# =========================================================
#
# PHASE 5 IMPROVEMENT
# ---------------------------------------------------------
# REMOVED HARDCODED REGION
#
# OLD:
# region = "eu-west-1"
#
# NEW:
# region = var.aws_region
#
# BENEFITS:
# - Multi-region support
# - AWS portability
# - Environment portability
# - Production-ready Terraform design
# =========================================================

provider "aws" {

  region = var.aws_region
}

# =========================================================
# VPC MODULE
# =========================================================

module "vpc" {

  source = "../../modules/vpc"

  # =======================================================
  # ENVIRONMENT NAME
  # =======================================================

  environment = var.environment

  # =======================================================
  # NETWORK CONFIGURATION
  # =======================================================

  vpc_cidr = var.vpc_cidr
}

# =========================================================
# EKS MODULE
# =========================================================

module "eks" {

  source = "../../modules/eks"

  # =======================================================
  # ENVIRONMENT
  # =======================================================

  environment = var.environment

  # =======================================================
  # AWS REGION
  # =======================================================

  aws_region = var.aws_region

  # =======================================================
  # NETWORK
  # =======================================================

  private_subnets = module.vpc.private_subnet_ids
}

# =========================================================
# VPN MODULE
# =========================================================

module "vpn" {

  source = "../../modules/vpn"

  # =======================================================
  # ENVIRONMENT
  # =======================================================

  environment = var.environment

  # =======================================================
  # NETWORK
  # =======================================================

  vpc_id          = module.vpc.vpc_id
  vpc_cidr        = module.vpc.vpc_cidr
  private_subnets = module.vpc.private_subnet_ids

  # =======================================================
  # CERTIFICATES
  # =======================================================

  client_root_certificate_arn = var.client_root_certificate_arn

  server_certificate_arn = var.server_certificate_arn
}