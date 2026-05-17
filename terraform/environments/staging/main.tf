# =========================================================
# AWS PROVIDER (PORTABLE)
# =========================================================

provider "aws" {
  region = var.aws_region
}

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

# =========================================================
# OUTPUTS
# =========================================================

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "private_subnets" {
  value = module.vpc.private_subnet_ids
}

output "cluster_name" {
  value = module.eks.cluster_name
}

output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "vpn_endpoint_id" {
  value = module.vpn.client_vpn_endpoint_id
}