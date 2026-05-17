#!/bin/bash

# ============================================================
# DEVOPS INFRASTRUCTURE PLATFORM
# APPLICATION DEPLOYMENT ENGINE
# ============================================================
#
# FEATURES:
# - Environment-aware deployment
# - Multi-account compatible
# - Multi-region compatible
# - Centralized configuration loading
# - Namespace-aware deployment
# - Kubernetes validation
# - Rollout validation
# - Production-grade reusable deployment
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
# HEADER
# ============================================================

echo -e "${BLUE}"
echo "=================================================="
echo " Kubernetes Application Deployment Engine"
echo "=================================================="
echo -e "${NC}"

echo "Selected Environment: $ENVIRONMENT"

# ============================================================
# LOAD CONFIGURATION
# ============================================================

chmod +x "$ROOT_DIR/scripts/load-env.sh"

source "$ROOT_DIR/scripts/load-env.sh"

# ============================================================
# VALIDATE REQUIRED VARIABLES
# ============================================================

REQUIRED_VARIABLES=(
  ENVIRONMENT
  APP_NAMESPACE
  AWS_REGION
)

echo ""
echo -e "${BLUE}Validating Configuration...${NC}"

for VAR in "${REQUIRED_VARIABLES[@]}"; do

  if [ -z "${!VAR:-}" ]; then
    echo -e "${RED}ERROR:${NC} Missing variable: $VAR"
    exit 1
  fi

  echo -e "${GREEN}✔${NC} $VAR loaded"

done

# ============================================================
# VALIDATE REQUIRED TOOLS
# ============================================================

echo ""
echo -e "${BLUE}Checking Required Tools...${NC}"

REQUIRED_COMMANDS=(
  kubectl
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
# VALIDATE KUBERNETES CONNECTIVITY
# ============================================================

echo ""
echo -e "${BLUE}Validating Kubernetes Connectivity...${NC}"

kubectl cluster-info >/dev/null

echo -e "${GREEN}✔ Kubernetes cluster reachable${NC}"

# ============================================================
# SHOW ACTIVE CONFIGURATION
# ============================================================

echo ""
echo -e "${BLUE}Active Deployment Configuration${NC}"

echo "Environment : $ENVIRONMENT"
echo "Namespace   : $APP_NAMESPACE"
echo "AWS Region  : $AWS_REGION"

# ============================================================
# DEPLOY BASE RESOURCES
# ============================================================

echo ""
echo -e "${BLUE}Deploying Base Resources...${NC}"

kubectl apply -f "$ROOT_DIR/k8s/base/"

# ============================================================
# DEPLOY DATABASE LAYER
# ============================================================

echo ""
echo -e "${BLUE}Deploying MongoDB...${NC}"

kubectl apply -f "$ROOT_DIR/k8s/apps/mongodb/"

# ============================================================
# WAIT FOR MONGODB
# ============================================================

echo ""
echo -e "${BLUE}Waiting For MongoDB StatefulSet...${NC}"

kubectl rollout status statefulset/mongodb \
  -n "$APP_NAMESPACE" \
  --timeout=300s

# ============================================================
# DEPLOY BACKEND
# ============================================================

echo ""
echo -e "${BLUE}Deploying Backend Application...${NC}"

kubectl apply -f "$ROOT_DIR/k8s/apps/backend/"

# ============================================================
# WAIT FOR BACKEND
# ============================================================

echo ""
echo -e "${BLUE}Waiting For Backend Deployment...${NC}"

kubectl rollout status deployment/backend \
  -n "$APP_NAMESPACE" \
  --timeout=300s

# ============================================================
# DEPLOY FRONTEND
# ============================================================

echo ""
echo -e "${BLUE}Deploying Frontend Application...${NC}"

kubectl apply -f "$ROOT_DIR/k8s/apps/frontend/"

# ============================================================
# WAIT FOR FRONTEND
# ============================================================

echo ""
echo -e "${BLUE}Waiting For Frontend Deployment...${NC}"

kubectl rollout status deployment/frontend \
  -n "$APP_NAMESPACE" \
  --timeout=300s

# ============================================================
# VALIDATE DEPLOYMENTS
# ============================================================

echo ""
echo -e "${BLUE}Deployment Validation${NC}"

kubectl get deployments -n "$APP_NAMESPACE"

echo ""
kubectl get statefulsets -n "$APP_NAMESPACE"

echo ""
kubectl get pods -n "$APP_NAMESPACE"

echo ""
kubectl get svc -n "$APP_NAMESPACE"

echo ""
kubectl get ingress -n "$APP_NAMESPACE"

# ============================================================
# SUCCESS MESSAGE
# ============================================================

echo ""
echo -e "${GREEN}"
echo "=================================================="
echo " Application Deployment Completed Successfully"
echo "=================================================="
echo -e "${NC}"

echo "Environment : $ENVIRONMENT"
echo "Namespace   : $APP_NAMESPACE"
echo "AWS Region  : $AWS_REGION"