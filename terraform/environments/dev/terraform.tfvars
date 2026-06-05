# =========================================================
# ENVIRONMENT

environment = "dev"

# =========================================================
# AWS REGION
# =========================================================

aws_region = "eu-west-1"

# =========================================================
# NETWORK
# =========================================================

vpc_cidr = "10.0.0.0/16"

availability_zones = [
  "eu-west-1a",
  "eu-west-1b"
]

public_subnet_cidrs = [
  "10.0.1.0/24",
  "10.0.2.0/24"
]

private_subnet_cidrs = [
  "10.0.10.0/24",
  "10.0.11.0/24"
]

domain_name = "dev.internal"


kubernetes_version = "1.31"

# =========================================================
# VPN CERTIFICATES
# =========================================================
server_certificate_arn = "arn:aws:acm:eu-west-1:744804011934:certificate/bb7823d5-298d-4a4a-b3b7-e94c14214862"

client_root_certificate_arn = "arn:aws:acm:eu-west-1:744804011934:certificate/f83580e6-3cbf-45bb-90de-1cf7d30bfc94"

# =========================================================
# EKS
# =========================================================

cluster_name = "devops-cluster"

node_group_name = "dev-node-group"

instance_types = ["t3.large"]

desired_size = 3
min_size     = 1
max_size     = 6