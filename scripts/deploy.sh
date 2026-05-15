#!/bin/bash

# ============================================================
# DEVOPS INFRASTRUCTURE PLATFORM
# APPLICATION DEPLOYMENT SCRIPT
# ============================================================
#
# PURPOSE:
# Deploy Kubernetes workloads dynamically.
#
# FEATURES:
# - Centralized config loading
# - Dynamic environment support
# - Kubernetes validation
# - Namespace-aware deployment
# - Reusable globally
# - Production-grade logging
#
# ============================================================

set -e

# ============================================================
# DEFAULT ENVIRONMENT
# ============================================================

export ENVIRONMENT=${ENVIRONMENT:-dev}

# ============================================================
# LOAD ENVIRONMENT CONFIGURATION
# ============================================================

source scripts/load-env.sh

# ============================================================
# COLORS
# ============================================================

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# ============================================================
# HEADER
# ============================================================

echo -e "${GREEN}"
echo "======================================"
echo " Kubernetes Application Deployment"
echo "======================================"
echo -e "${NC}"

# ============================================================
# SHOW ACTIVE CONFIGURATION
# ============================================================

echo -e "${YELLOW}Environment:${NC} ${ENVIRONMENT}"
echo -e "${YELLOW}Namespace:${NC} ${APP_NAMESPACE}"

echo ""

# ============================================================
# VALIDATE KUBERNETES CONNECTIVITY
# ============================================================

echo -e "${YELLOW}Validating Kubernetes Connectivity...${NC}"

kubectl cluster-info >/dev/null

echo "Kubernetes cluster reachable"

echo ""

# ============================================================
# DEPLOY BASE RESOURCES
# ============================================================

echo -e "${YELLOW}Deploying Base Resources...${NC}"

kubectl apply -f k8s/base/

echo ""

# ============================================================
# DEPLOY MONGODB
# ============================================================

echo -e "${YELLOW}Deploying MongoDB...${NC}"

kubectl apply -f k8s/apps/mongodb/

echo ""

# ============================================================
# DEPLOY BACKEND
# ============================================================

echo -e "${YELLOW}Deploying Backend Application...${NC}"

kubectl apply -f k8s/apps/backend/

echo ""

# ============================================================
# DEPLOY FRONTEND
# ============================================================

echo -e "${YELLOW}Deploying Frontend Application...${NC}"

kubectl apply -f k8s/apps/frontend/

echo ""

# ============================================================
# VALIDATE DEPLOYMENTS
# ============================================================

echo -e "${YELLOW}Validating Deployments...${NC}"

kubectl get deployments -n ${APP_NAMESPACE}

echo ""

# ============================================================
# VALIDATE PODS
# ============================================================

echo -e "${YELLOW}Validating Pods...${NC}"

kubectl get pods -n ${APP_NAMESPACE}

echo ""

# ============================================================
# VALIDATE SERVICES
# ============================================================

echo -e "${YELLOW}Validating Services...${NC}"

kubectl get svc -n ${APP_NAMESPACE}

echo ""

# ============================================================
# SUCCESS MESSAGE
# ============================================================

echo -e "${GREEN}"
echo "======================================"
echo " Application Deployment Completed"
echo "======================================"
echo -e "${NC}"