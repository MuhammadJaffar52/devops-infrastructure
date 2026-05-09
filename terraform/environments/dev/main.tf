provider "aws" {
  region = "eu-west-1"
}

module "vpc" {
  source = "../../modules/vpc"
}

module "eks" {
  source = "../../modules/eks"

  private_subnets = module.vpc.private_subnets
}


