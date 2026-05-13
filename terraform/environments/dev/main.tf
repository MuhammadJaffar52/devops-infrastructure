provider "aws" {
  region = "eu-west-1"
}

module "vpc" {
  source = "../../modules/vpc"
}

module "eks" {
  source = "../../modules/eks"

  private_subnets = module.vpc.private_subnet_ids
}

module "vpn" {
  source = "../../modules/vpn"

  vpc_id          = module.vpc.vpc_id
  vpc_cidr        = module.vpc.vpc_cidr
  private_subnets = module.vpc.private_subnet_ids

  client_root_certificate_arn = var.client_root_certificate_arn
  server_certificate_arn      = var.server_certificate_arn
}