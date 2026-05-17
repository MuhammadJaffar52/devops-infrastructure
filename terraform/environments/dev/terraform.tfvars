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

# =========================================================
# VPN CERTIFICATES
# =========================================================
server_certificate_arn = "arn:aws:acm:eu-west-1:744804011934:certificate/bb7823d5-298d-4a4a-b3b7-e94c14214862"

client_root_certificate_arn = "arn:aws:acm:eu-west-1:744804011934:certificate/f83580e6-3cbf-45bb-90de-1cf7d30bfc94"

# =========================================================
# EKS NODE CONFIG (ADD THIS - IMPORTANT)
# =========================================================

node_instance_type = "t3.medium"
node_min_size      = 1
node_max_size      = 3
node_desired_size  = 2