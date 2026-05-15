locals {
  aws_account_id = data.aws_caller_identity.current.account_id
  region        = "eu-west-1"
  project_name  = "devops-infrastructure"

  eks_cluster   = "devops-eks"
  environment   = var.environment

  domain_name   = var.domain_name
}