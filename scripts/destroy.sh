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
# - Dynamic environment support
# - Centralized configuration loading
# - Terraform validation
# - Confirmation protection
# - Multi-account compatible
# - Multi-region compatible
# - Reusable globally
#
# ============================================================

set -e

# ============================================================
# DEFAULT ENVIRONMENT
# ============================================================

export ENVIRONMENT=${ENVIRONMENT:-dev}

# ============================================================
# LOAD CENTRALIZED CONFIGURATION
# ============================================================

source scripts/load-env.sh

# ============================================================
# COLORS
# ============================================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# ============================================================
# HEADER
# ============================================================

echo -e "${RED}"
echo "======================================"
echo " Destroying Infrastructure Platform"
echo "======================================"
echo -e "${NC}"

# ============================================================
# SHOW ACTIVE CONFIGURATION
# ============================================================

echo -e "${YELLOW}Environment:${NC} ${ENVIRONMENT}"
echo -e "${YELLOW}AWS Region:${NC} ${AWS_REGION}"

echo ""

# ============================================================
# SAFETY CONFIRMATION
# ============================================================

read -p "Are you sure you want to DESTROY this infrastructure? (yes/no): " confirm

if [ "$confirm" != "yes" ]; then
  echo ""
  echo -e "${RED}Infrastructure destruction aborted.${NC}"
  exit 1
fi

# ============================================================
# MOVE TO TERRAFORM ENVIRONMENT
# ============================================================

cd terraform/environments/${ENVIRONMENT}

# ============================================================
# INITIALIZE TERRAFORM
# ============================================================

echo ""
echo -e "${YELLOW}Initializing Terraform...${NC}"

terraform init

# ============================================================
# VALIDATE TERRAFORM
# ============================================================

echo ""
echo -e "${YELLOW}Validating Terraform Configuration...${NC}"

terraform validate

# ============================================================
# DESTROY INFRASTRUCTURE
# ============================================================

echo ""
echo -e "${RED}Destroying Infrastructure...${NC}"

terraform destroy -auto-approve

# ============================================================
# COMPLETED
# ============================================================

echo ""
echo -e "${GREEN}======================================${NC}"
echo -e "${GREEN}Infrastructure Destroyed Successfully${NC}"
echo -e "${GREEN}======================================${NC}"