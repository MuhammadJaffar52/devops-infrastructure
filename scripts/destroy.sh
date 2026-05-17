#!/bin/bash

# ============================================================
# DEVOPS INFRASTRUCTURE PLATFORM
# DESTROY SCRIPT
# ============================================================
#
# PURPOSE:
# Safely destroy infrastructure for any environment.
#
# FEATURES:
# - Multi-account AWS support
# - Multi-region support
# - Environment-aware execution
# - Centralized configuration loading
# - Terraform validation
# - AWS identity validation
# - Safer destruction workflow
# - Production-grade logging
#
# ============================================================

set -euo pipefail

# ============================================================
# COLORS
# ============================================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
NC='\033[0m'

# ============================================================
# ROOT DIRECTORY
# ============================================================

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)

# ============================================================
# DEFAULT ENVIRONMENT
# ============================================================

export ENVIRONMENT=${ENVIRONMENT:-dev}

# ============================================================
# LOAD ENVIRONMENT CONFIGURATION
# ============================================================

source "$ROOT_DIR/scripts/load-env.sh"

# ============================================================
# HEADER
# ============================================================

echo -e "${RED}"
echo "=================================================="
echo " DevOps Infrastructure Destroy"
echo "=================================================="
echo -e "${NC}"

# ============================================================
# SHOW ACTIVE CONFIGURATION
# ============================================================

echo -e "${YELLOW}Environment:${NC} ${ENVIRONMENT}"
echo -e "${YELLOW}AWS Region:${NC} ${AWS_REGION}"

echo ""

# ============================================================
# VERIFY REQUIRED TOOLS
# ============================================================

echo -e "${BLUE}Checking Required Tools...${NC}"

REQUIRED_COMMANDS=(
  aws
  terraform
)

for cmd in "${REQUIRED_COMMANDS[@]}"; do

  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo -e "${RED}ERROR:${NC} $cmd is not installed"
    exit 1
  fi

  echo -e "${GREEN}✔${NC} $cmd installed"
done

# ============================================================
# VERIFY AWS ACCESS
# ============================================================

echo ""
echo -e "${BLUE}Verifying AWS Access...${NC}"

AWS_ACCOUNT_ID=$(aws sts get-caller-identity \
  --query Account \
  --output text)

echo "Connected AWS Account:"
echo "$AWS_ACCOUNT_ID"

# ============================================================
# TERRAFORM DIRECTORY
# ============================================================

TF_DIR="$ROOT_DIR/terraform/environments/${ENVIRONMENT}"

if [ ! -d "$TF_DIR" ]; then
  echo -e "${RED}ERROR:${NC} Terraform environment not found:"
  echo "$TF_DIR"
  exit 1
fi

# ============================================================
# SAFETY CONFIRMATION
# ============================================================

echo ""
echo -e "${RED}WARNING:${NC} This will permanently destroy:"
echo "- VPC"
echo "- EKS Cluster"
echo "- Node Groups"
echo "- Load Balancers"
echo "- Security Groups"
echo "- Terraform-managed resources"

echo ""

read -p "Type the environment name (${ENVIRONMENT}) to continue: " confirm

if [ "$confirm" != "$ENVIRONMENT" ]; then
  echo ""
  echo -e "${RED}Infrastructure destruction aborted.${NC}"
  exit 1
fi

# ============================================================
# MOVE TO TERRAFORM ENVIRONMENT
# ============================================================

cd "$TF_DIR"

# ============================================================
# INITIALIZE TERRAFORM
# ============================================================

echo ""
echo -e "${BLUE}Initializing Terraform...${NC}"

terraform init

# ============================================================
# VALIDATE TERRAFORM
# ============================================================

echo ""
echo -e "${BLUE}Validating Terraform Configuration...${NC}"

terraform validate

# ============================================================
# TERRAFORM DESTROY
# ============================================================

echo ""
echo -e "${RED}Destroying Infrastructure...${NC}"

terraform destroy \
  -auto-approve \
  -var="aws_region=${AWS_REGION}" \
  -var="environment=${ENVIRONMENT}"

# ============================================================
# COMPLETED
# ============================================================

echo ""
echo -e "${GREEN}"
echo "=================================================="
echo " Infrastructure Destroyed Successfully"
echo "=================================================="
echo -e "${NC}"

echo "Environment: ${ENVIRONMENT}"
echo "AWS Region: ${AWS_REGION}"
echo "AWS Account ID: ${AWS_ACCOUNT_ID}"