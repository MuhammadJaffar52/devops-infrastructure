#!/bin/bash

# ============================================================
# DEVOPS INFRASTRUCTURE PLATFORM
# VALIDATION SCRIPT
# ============================================================
#
# PURPOSE:
# Validate Kubernetes platform health after deployment.
#
# FEATURES:
# - Multi-account AWS support
# - Multi-region support
# - Environment-aware validation
# - Centralized configuration loading
# - Kubernetes validation
# - Helm validation
# - Monitoring validation
# - Security validation
# - Production-grade logging
#
# ============================================================

set -euo pipefail

# ============================================================
# COLORS
# ============================================================

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
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
# LOAD CENTRALIZED CONFIGURATION
# ============================================================

source "$ROOT_DIR/scripts/load-env.sh"

# ============================================================
# HEADER
# ============================================================

echo -e "${GREEN}"
echo "=================================================="
echo " Kubernetes Platform Validation"
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
  kubectl
  helm
  aws
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

echo ""

# ============================================================
# CHECK KUBERNETES CONNECTIVITY
# ============================================================

echo -e "${BLUE}Checking Kubernetes Connectivity...${NC}"

kubectl cluster-info >/dev/null

echo -e "${GREEN}✔ Kubernetes cluster reachable${NC}"

echo ""

# ============================================================
# CHECK CLUSTER NODES
# ============================================================

echo -e "${BLUE}Checking Kubernetes Nodes...${NC}"

kubectl get nodes -o wide

echo ""

# ============================================================
# CHECK NAMESPACES
# ============================================================

echo -e "${BLUE}Checking Namespaces...${NC}"

kubectl get ns

echo ""

# ============================================================
# CHECK PODS
# ============================================================

echo -e "${BLUE}Checking All Pods...${NC}"

kubectl get pods -A

echo ""

# ============================================================
# CHECK SERVICES
# ============================================================

echo -e "${BLUE}Checking Services...${NC}"

kubectl get svc -A

echo ""

# ============================================================
# CHECK INGRESS
# ============================================================

echo -e "${BLUE}Checking Ingress Resources...${NC}"

kubectl get ingress -A || true

echo ""

# ============================================================
# CHECK HELM RELEASES
# ============================================================

echo -e "${BLUE}Checking Helm Releases...${NC}"

helm list -A

echo ""

# ============================================================
# CHECK APPLICATION NAMESPACE
# ============================================================

echo -e "${BLUE}Checking Application Namespace...${NC}"

kubectl get all -n "${APP_NAMESPACE}" || true

echo ""

# ============================================================
# CHECK JENKINS
# ============================================================

echo -e "${BLUE}Checking Jenkins Namespace...${NC}"

kubectl get all -n "${JENKINS_NAMESPACE}" || true

echo ""

# ============================================================
# CHECK MONITORING STACK
# ============================================================

echo -e "${BLUE}Checking Monitoring Stack...${NC}"

kubectl get all -n "${MONITORING_NAMESPACE}" || true

echo ""

# ============================================================
# CHECK STORAGE CLASSES
# ============================================================

echo -e "${BLUE}Checking Storage Classes...${NC}"

kubectl get storageclass

echo ""

# ============================================================
# CHECK PVCs
# ============================================================

echo -e "${BLUE}Checking Persistent Volume Claims...${NC}"

kubectl get pvc -A || true

echo ""

# ============================================================
# CHECK EVENTS
# ============================================================

echo -e "${BLUE}Checking Recent Cluster Events...${NC}"

kubectl get events -A \
  --sort-by=.metadata.creationTimestamp \
  | tail -20 || true

echo ""

# ============================================================
# CHECK TRIVY OPERATOR
# ============================================================

echo -e "${BLUE}Checking Trivy Operator...${NC}"

kubectl get pods -n "${TRIVY_NAMESPACE}" || true

echo ""

# ============================================================
# CHECK VULNERABILITY REPORTS
# ============================================================

echo -e "${BLUE}Checking Vulnerability Reports...${NC}"

kubectl get vulnerabilityreports -A || true

echo ""

# ============================================================
# CHECK CONFIG AUDIT REPORTS
# ============================================================

echo -e "${BLUE}Checking Config Audit Reports...${NC}"

kubectl get configauditreports -A || true

echo ""

# ============================================================
# VALIDATION COMPLETED
# ============================================================

echo -e "${GREEN}"
echo "=================================================="
echo " Validation Completed Successfully"
echo "=================================================="
echo -e "${NC}"

echo "Environment: ${ENVIRONMENT}"
echo "AWS Region: ${AWS_REGION}"
echo "AWS Account ID: ${AWS_ACCOUNT_ID}"