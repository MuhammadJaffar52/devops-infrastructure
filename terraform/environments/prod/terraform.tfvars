# =========================================================
# ENVIRONMENT
# =========================================================
#
# Supported:
# - dev
# - staging
# - prod
# =========================================================

environment = "dev"

# =========================================================
# AWS REGION
# =========================================================
#
# Examples:
# - eu-west-1
# - us-east-1
# - ap-south-1
#
# PHASE 5 IMPROVEMENT:
# Region is now fully configurable.
# =========================================================

aws_region = "eu-west-1"

# =========================================================
# NETWORKING
# =========================================================
#
# VPC CIDR RANGE
#
# IMPORTANT:
# Ensure this CIDR does not overlap with:
# - office VPN
# - existing VPCs
# - peered networks
# =========================================================

vpc_cidr = "10.0.0.0/16"

# =========================================================
# DOMAIN
# =========================================================
#
# Internal domain used for:
# - ingress
# - internal DNS
# - service routing
# =========================================================

domain_name = "dev.internal"

# =========================================================
# AWS CLIENT VPN CERTIFICATES
# =========================================================
#
# ACM Certificate ARNs
#
# Replace placeholders with actual ACM certificate ARNs.
# =========================================================

server_certificate_arn =
  "YOUR_SERVER_CERT_ARN"

client_root_certificate_arn =
  "YOUR_CLIENT_CERT_ARN"