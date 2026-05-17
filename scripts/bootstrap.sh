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
# - Production-grade reusable deployment
# - Idempotent deployment flow
# - Centralized configuration loading
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
# ENVIRONMENT
# ============================================================

export ENVIRONMENT=${ENVIRONMENT:-dev}

# ============================================================
# LOAD ENVIRONMENT CONFIGURATION
# ============================================================

echo -e "${BLUE}"
echo "=================================================="
echo " DevOps Infrastructure Bootstrap"
echo "=================================================="
echo -e "${NC}"

echo "Selected Environment: $ENVIRONMENT"

chmod +x "$ROOT_DIR/scripts/load-env.sh"

source "$ROOT_DIR/scripts/load-env.sh"

# ============================================================
# REQUIRED VARIABLES VALIDATION
# ============================================================

REQUIRED_VARIABLES=(
  AWS_REGION
  ENVIRONMENT
  APP_NAMESPACE
  JENKINS_NAMESPACE
  MONITORING_NAMESPACE
  TRIVY_NAMESPACE
)

echo ""
echo -e "${BLUE}Validating Required Variables...${NC}"

for VAR in "${REQUIRED_VARIABLES[@]}"; do

  if [ -z "${!VAR:-}" ]; then
    echo -e "${RED}ERROR:${NC} Missing variable: $VAR"
    exit 1
  fi

  echo -e "${GREEN}✔${NC} $VAR loaded"

done

# ============================================================
# CHECK REQUIRED TOOLS
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

AWS_USER_ARN=$(aws sts get-caller-identity \
  --query Arn \
  --output text)

echo ""
echo "AWS Account ID : $AWS_ACCOUNT_ID"
echo "AWS Identity   : $AWS_USER_ARN"

# ============================================================
# TERRAFORM ENVIRONMENT DIRECTORY
# ============================================================

TF_DIR="$ROOT_DIR/terraform/environments/$ENVIRONMENT"

if [ ! -d "$TF_DIR" ]; then

  echo -e "${RED}ERROR:${NC} Terraform environment not found:"
  echo "$TF_DIR"

  exit 1
fi

# ============================================================
# TERRAFORM INITIALIZATION
# ============================================================

echo ""
echo -e "${BLUE}Initializing Terraform...${NC}"

cd "$TF_DIR"

terraform init

# ============================================================
# TERRAFORM FORMAT VALIDATION
# ============================================================

echo ""
echo -e "${BLUE}Checking Terraform Formatting...${NC}"

terraform fmt -check -recursive

# ============================================================
# TERRAFORM VALIDATION
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
# FETCH TERRAFORM OUTPUTS
# ============================================================

echo ""
echo -e "${BLUE}Fetching Terraform Outputs...${NC}"

CLUSTER_NAME=$(terraform output -raw eks_cluster_name)

AWS_REGION_OUTPUT=$(terraform output -raw aws_region)

echo ""
echo "EKS Cluster : $CLUSTER_NAME"
echo "AWS Region  : $AWS_REGION_OUTPUT"

# ============================================================
# UPDATE KUBECONFIG
# ============================================================

echo ""
echo -e "${BLUE}Updating kubeconfig...${NC}"

aws eks update-kubeconfig \
  --region "$AWS_REGION_OUTPUT" \
  --name "$CLUSTER_NAME"

# ============================================================
# VERIFY KUBERNETES ACCESS
# ============================================================

echo ""
echo -e "${BLUE}Verifying Kubernetes Access...${NC}"

kubectl cluster-info

kubectl get nodes

# ============================================================
# DEPLOY BASE RESOURCES
# ============================================================

echo ""
echo -e "${BLUE}Deploying Base Kubernetes Resources...${NC}"

cd "$ROOT_DIR"

kubectl apply -f k8s/base/

# ============================================================
# DEPLOY HELM RELEASES
# ============================================================

echo ""
echo -e "${BLUE}Deploying Helm Releases...${NC}"

cd "$ROOT_DIR/helm"

helmfile sync

# ============================================================
# DEPLOY PLATFORM COMPONENTS
# ============================================================

echo ""
echo -e "${BLUE}Deploying Platform Components...${NC}"

cd "$ROOT_DIR"

kubectl apply -f k8s/platform/

# ============================================================
# DEPLOY MONITORING COMPONENTS
# ============================================================

echo ""
echo -e "${BLUE}Deploying Monitoring Components...${NC}"

kubectl apply -f k8s/monitoring/

# ============================================================
# DEPLOY APPLICATIONS
# ============================================================

echo ""
echo -e "${BLUE}Deploying Applications...${NC}"

kubectl apply -f k8s/apps/

# ============================================================
# WAIT FOR DEPLOYMENTS
# ============================================================

echo ""
echo -e "${BLUE}Waiting For Deployments...${NC}"

kubectl rollout status deployment/frontend \
  -n "$APP_NAMESPACE" \
  --timeout=300s || true

kubectl rollout status deployment/backend \
  -n "$APP_NAMESPACE" \
  --timeout=300s || true

# ============================================================
# FINAL VALIDATION
# ============================================================

echo ""
echo -e "${BLUE}Cluster Resource Summary${NC}"

kubectl get pods -A

echo ""
kubectl get svc -A

echo ""
kubectl get ingress -A

# ============================================================
# SUCCESS MESSAGE
# ============================================================

echo ""
echo -e "${GREEN}"
echo "=================================================="
echo " Bootstrap Completed Successfully"
echo "=================================================="
echo -e "${NC}"

echo "Environment  : $ENVIRONMENT"
echo "AWS Account  : $AWS_ACCOUNT_ID"
echo "AWS Region   : $AWS_REGION"
echo "EKS Cluster  : $CLUSTER_NAME"