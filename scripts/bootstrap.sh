#!/bin/bash

set -e

export ENVIRONMENT=${ENVIRONMENT:-dev}

echo "======================================"
echo "DevOps Infrastructure Bootstrap"
echo "======================================"

ROOT_DIR=$(pwd)

echo ""
echo "Checking dependencies..."

for cmd in aws kubectl terraform helm helmfile; do
  command -v $cmd >/dev/null 2>&1 || {
    echo "$cmd not installed"
    exit 1
  }
done

echo ""
echo "Initializing Terraform..."

cd terraform/environments/$ENVIRONMENT

terraform init

echo ""
echo "Applying Terraform..."

terraform apply -auto-approve

echo ""
echo "Updating kubeconfig..."

CLUSTER_NAME=$(terraform output -raw eks_cluster_name)

AWS_REGION=$(terraform output -raw aws_region)

aws eks update-kubeconfig \
  --region $AWS_REGION \
  --name $CLUSTER_NAME

echo ""
echo "Deploying Helm releases..."

cd $ROOT_DIR/helm

helmfile sync

echo ""
echo "Deploying Kubernetes apps..."

cd $ROOT_DIR

kubectl apply -f k8s/base/
kubectl apply -f k8s/apps/

echo ""
echo "Bootstrap completed successfully."