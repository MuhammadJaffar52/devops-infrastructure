locals {
  region        = "eu-west-1"
  project_name  = "devops-infrastructure"

  eks_cluster   = "devops-eks"
  environment   = var.environment

  domain_name   = var.domain_name
}