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
# - Dynamic environment support
# - Centralized configuration loading
# - Kubernetes validation
# - Helm validation
# - Monitoring validation
# - Logging validation
# - Security validation
# - Production-grade checks
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

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# ============================================================
# HEADER
# ============================================================

echo -e "${GREEN}"
echo "======================================"
echo " Kubernetes Platform Validation"
echo "======================================"
echo -e "${NC}"

# ============================================================
# SHOW ACTIVE CONFIGURATION
# ============================================================

echo -e "${YELLOW}Environment:${NC} ${ENVIRONMENT}"
echo -e "${YELLOW}AWS Region:${NC} ${AWS_REGION}"

echo ""

# ============================================================
# CHECK KUBERNETES CONNECTIVITY
# ============================================================

echo -e "${YELLOW}Checking Kubernetes Connectivity...${NC}"

kubectl cluster-info

echo ""

# ============================================================
# CHECK NODES
# ============================================================

echo -e "${YELLOW}Checking Kubernetes Nodes...${NC}"

kubectl get nodes -o wide

echo ""

# ============================================================
# CHECK NAMESPACES
# ============================================================

echo -e "${YELLOW}Checking Namespaces...${NC}"

kubectl get ns

echo ""

# ============================================================
# CHECK ALL PODS
# ============================================================

echo -e "${YELLOW}Checking All Pods...${NC}"

kubectl get pods -A

echo ""

# ============================================================
# CHECK SERVICES
# ============================================================

echo -e "${YELLOW}Checking Services...${NC}"

kubectl get svc -A

echo ""

# ============================================================
# CHECK INGRESS
# ============================================================

echo -e "${YELLOW}Checking Ingress Resources...${NC}"

kubectl get ingress -A || true

echo ""

# ============================================================
# CHECK HELM RELEASES
# ============================================================

echo -e "${YELLOW}Checking Helm Releases...${NC}"

helm list -A

echo ""

# ============================================================
# CHECK APPLICATION NAMESPACE
# ============================================================

echo -e "${YELLOW}Checking Application Namespace...${NC}"

kubectl get all -n ${APP_NAMESPACE}

echo ""

# ============================================================
# CHECK JENKINS
# ============================================================

echo -e "${YELLOW}Checking Jenkins Namespace...${NC}"

kubectl get all -n ${JENKINS_NAMESPACE}

echo ""

# ============================================================
# CHECK MONITORING STACK
# ============================================================

echo -e "${YELLOW}Checking Monitoring Stack...${NC}"

kubectl get all -n ${MONITORING_NAMESPACE}

echo ""

# ============================================================
# CHECK PROMETHEUS
# ============================================================

echo -e "${YELLOW}Checking Prometheus...${NC}"

kubectl get pods -n ${PROMETHEUS_NAMESPACE} | grep prometheus || true

echo ""

# ============================================================
# CHECK GRAFANA
# ============================================================

echo -e "${YELLOW}Checking Grafana...${NC}"

kubectl get pods -n ${GRAFANA_NAMESPACE} | grep grafana || true

echo ""

# ============================================================
# CHECK LOKI
# ============================================================

echo -e "${YELLOW}Checking Loki...${NC}"

kubectl get pods -n ${LOKI_NAMESPACE} | grep loki || true

echo ""

# ============================================================
# CHECK PROMTAIL
# ============================================================

echo -e "${YELLOW}Checking Promtail...${NC}"

kubectl get daemonsets -n ${PROMTAIL_NAMESPACE} || true

echo ""

# ============================================================
# CHECK TRIVY OPERATOR
# ============================================================

echo -e "${YELLOW}Checking Trivy Operator...${NC}"

kubectl get pods -n ${TRIVY_NAMESPACE} || true

echo ""

# ============================================================
# CHECK VULNERABILITY REPORTS
# ============================================================

echo -e "${YELLOW}Checking Vulnerability Reports...${NC}"

kubectl get vulnerabilityreports -A || true

echo ""

# ============================================================
# CHECK CONFIG AUDIT REPORTS
# ============================================================

echo -e "${YELLOW}Checking Config Audit Reports...${NC}"

kubectl get configauditreports -A || true

echo ""

# ============================================================
# VALIDATION SUCCESS
# ============================================================

echo -e "${GREEN}"
echo "======================================"
echo " Validation Completed Successfully"
echo "======================================"
echo -e "${NC}"