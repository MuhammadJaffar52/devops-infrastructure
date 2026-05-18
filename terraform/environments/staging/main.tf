# =========================================================
# AWS PROVIDER (PORTABLE)
# =========================================================


# =========================================================
# VPC MODULE
# =========================================================

module "vpc" {
  source = "../../modules/vpc"

  environment = var.environment
  vpc_cidr    = var.vpc_cidr
}

# =========================================================
# EKS MODULE
# =========================================================

module "eks" {
  source = "../../modules/eks"

  aws_region      = var.aws_region
  environment     = var.environment
  private_subnets = module.vpc.private_subnet_ids
}

# =========================================================
# VPN MODULE
# =========================================================

module "vpn" {
  source = "../../modules/vpn"

  vpc_id          = module.vpc.vpc_id
  vpc_cidr        = module.vpc.vpc_cidr
  private_subnets = module.vpc.private_subnet_ids

  client_root_certificate_arn = var.client_root_certificate_arn
  server_certificate_arn      = var.server_certificate_arn
}
