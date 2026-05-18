# =========================================================
# PROVIDER (INHERITS GLOBAL CONFIG STANDARD)
# =========================================================



# =========================================================
# VPC MODULE
# =========================================================
module "vpc" {

  source = "../../modules/vpc"

  aws_region = var.aws_region

  environment = var.environment

  cluster_name = "${var.environment}-eks"

  vpc_cidr = var.vpc_cidr

  availability_zones = [
    "${var.aws_region}a",
    "${var.aws_region}b"
  ]

  public_subnet_cidrs = [
    "10.0.1.0/24",
    "10.0.2.0/24"
  ]

  private_subnet_cidrs = [
    "10.0.10.0/24",
    "10.0.11.0/24"
  ]
}
# =========================================================
# EKS MODULE
# =========================================================
# =========================================================
# EKS MODULE
# =========================================================

module "eks" {

  source = "../../modules/eks"

  aws_region  = var.aws_region
  environment = var.environment

  cluster_name       = var.cluster_name
  kubernetes_version = var.kubernetes_version
  private_subnets    = module.vpc.private_subnet_ids

  node_group_name = var.node_group_name

  instance_types = var.instance_types

  desired_size = var.desired_size
  min_size     = var.min_size
  max_size     = var.max_size
}
# =========================================================
# VPN MODULE
# =========================================================

module "vpn" {

  source      = "../../modules/vpn"
  environment = var.environment

  vpc_id          = module.vpc.vpc_id
  vpc_cidr        = module.vpc.vpc_cidr
  private_subnets = module.vpc.private_subnet_ids

  client_root_certificate_arn = var.client_root_certificate_arn
  server_certificate_arn      = var.server_certificate_arn
}
