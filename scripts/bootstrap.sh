#!/bin/bash

# ============================================================
# DevOps Infrastructure Bootstrap Script
# ============================================================
# PURPOSE:
# Fully automated infrastructure bootstrap
#
# FEATURES:
# - Multi-account AWS support
# - Multi-region support
# - Environment-based deployment
# - Dynamic configuration loading
# - Validation checks
# - Better logging
# - Production-grade reusable deployment
# ============================================================

set -euo pipefail

# ============================================================
# COLORS
# ============================================================

GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[1;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

# ============================================================
# ROOT DIRECTORY
# ============================================================

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)

# ============================================================
# ENVIRONMENT VALIDATION
# ============================================================

export ENVIRONMENT=${ENVIRONMENT:-dev}

CONFIG_FILE="$ROOT_DIR/configs/${ENVIRONMENT}.env"

echo -e "${BLUE}"
echo "=================================================="
echo " DevOps Infrastructure Bootstrap"
echo "=================================================="
echo -e "${NC}"

echo "Selected Environment: $ENVIRONMENT"

# ============================================================
# CHECK CONFIG FILE
# ============================================================

if [ ! -f "$CONFIG_FILE" ]; then
  echo -e "${RED}ERROR:${NC} Config file not found:"
  echo "$CONFIG_FILE"
  exit 1
fi

# ============================================================
# LOAD CONFIGURATION
# ============================================================

echo ""
echo -e "${BLUE}Loading Environment Configuration...${NC}"

source "$CONFIG_FILE"

echo ""
echo "Loaded Configuration:"
echo "AWS Region: $AWS_REGION"
echo "Environment: $ENVIRONMENT"

# ============================================================
# CHECK REQUIRED VARIABLES
# ============================================================

REQUIRED_VARIABLES=(
  AWS_REGION
  ENVIRONMENT
)

for VAR in "${REQUIRED_VARIABLES[@]}"; do
  if [ -z "${!VAR:-}" ]; then
    echo -e "${RED}ERROR:${NC} Missing variable: $VAR"
    exit 1
  fi
done

# ============================================================
# CHECK DEPENDENCIES
# ============================================================

echo ""
echo -e "${BLUE}Checking Required Tools...${NC}"

REQUIRED_COMMANDS=(
  aws
  kubectl
  terraform
  helm
  helmfile
)

for cmd in "${REQUIRED_COMMANDS[@]}"; do
  if ! command -v $cmd >/dev/null 2>&1; then
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

echo "Connected AWS Account ID:"
echo "$AWS_ACCOUNT_ID"

# ============================================================
# TERRAFORM DIRECTORY
# ============================================================

TF_DIR="$ROOT_DIR/terraform/environments/$ENVIRONMENT"

if [ ! -d "$TF_DIR" ]; then
  echo -e "${RED}ERROR:${NC} Terraform environment not found:"
  echo "$TF_DIR"
  exit 1
fi

# ============================================================
# TERRAFORM INIT
# ============================================================

echo ""
echo -e "${BLUE}Initializing Terraform...${NC}"

cd "$TF_DIR"

terraform init

# ============================================================
# TERRAFORM VALIDATE
# ============================================================

echo ""
echo -e "${BLUE}Validating Terraform...${NC}"

terraform validate

# ============================================================
# TERRAFORM PLAN
# ============================================================

echo ""
echo -e "${BLUE}Running Terraform Plan...${NC}"

terraform plan \
  -var="aws_region=$AWS_REGION" \
  -var="environment=$ENVIRONMENT"

# ============================================================
# TERRAFORM APPLY
# ============================================================

echo ""
echo -e "${BLUE}Applying Terraform Infrastructure...${NC}"

terraform apply -auto-approve \
  -var="aws_region=$AWS_REGION" \
  -var="environment=$ENVIRONMENT"

# ============================================================
# GET TERRAFORM OUTPUTS
# ============================================================

echo ""
echo -e "${BLUE}Fetching Terraform Outputs...${NC}"

CLUSTER_NAME=$(terraform output -raw eks_cluster_name)

AWS_REGION_OUTPUT=$(terraform output -raw aws_region)

echo "EKS Cluster:"
echo "$CLUSTER_NAME"

# ============================================================
# UPDATE KUBECONFIG
# ============================================================

echo ""
echo -e "${BLUE}Updating kubeconfig...${NC}"

aws eks update-kubeconfig \
  --region "$AWS_REGION_OUTPUT" \
  --name "$CLUSTER_NAME"

# ============================================================
# VERIFY CLUSTER ACCESS
# ============================================================

echo ""
echo -e "${BLUE}Verifying Kubernetes Cluster Access...${NC}"

kubectl get nodes

# ============================================================
# DEPLOY HELM RELEASES
# ============================================================

echo ""
echo -e "${BLUE}Deploying Helm Releases...${NC}"

cd "$ROOT_DIR/helm"

helmfile sync

# ============================================================
# DEPLOY BASE RESOURCES
# ============================================================

echo ""
echo -e "${BLUE}Deploying Base Kubernetes Resources...${NC}"

cd "$ROOT_DIR"

kubectl apply -f k8s/base/

# ============================================================
# DEPLOY PLATFORM COMPONENTS
# ============================================================

echo ""
echo -e "${BLUE}Deploying Platform Components...${NC}"

kubectl apply -f k8s/platform/

# ============================================================
# DEPLOY MONITORING STACK
# ============================================================

echo ""
echo -e "${BLUE}Deploying Monitoring Stack...${NC}"

kubectl apply -f k8s/monitoring/

# ============================================================
# DEPLOY APPLICATIONS
# ============================================================

echo ""
echo -e "${BLUE}Deploying Applications...${NC}"

kubectl apply -f k8s/apps/

# ============================================================
# FINAL VALIDATION
# ============================================================

echo ""
echo -e "${BLUE}Validating Deployments...${NC}"

kubectl get pods -A

# ============================================================
# SUCCESS MESSAGE
# ============================================================

echo ""
echo -e "${GREEN}"
echo "=================================================="
echo " Bootstrap Completed Successfully"
echo "=================================================="
echo -e "${NC}"

echo "Environment: $ENVIRONMENT"
echo "AWS Account: $AWS_ACCOUNT_ID"
echo "AWS Region: $AWS_REGION"
echo "EKS Cluster: $CLUSTER_NAME"