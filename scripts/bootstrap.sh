```bash
#!/bin/bash

set -e
export ENVIRONMENT=${ENVIRONMENT:-dev}

cd terraform/environments/$ENVIRONMENT
echo "======================================"
echo "DevOps Infrastructure Bootstrap"
echo "======================================"

echo ""
echo "Checking dependencies..."

command -v aws >/dev/null 2>&1 || {
  echo "AWS CLI not installed"
  exit 1
}

command -v kubectl >/dev/null 2>&1 || {
  echo "kubectl not installed"
  exit 1
}

command -v terraform >/dev/null 2>&1 || {
  echo "Terraform not installed"
  exit 1
}

command -v helm >/dev/null 2>&1 || {
  echo "Helm not installed"
  exit 1
}

echo ""
echo "Initializing Terraform..."

cd terraform/environments/dev

terraform init

echo ""
echo "Applying Terraform..."

terraform apply -auto-approve

echo ""
echo "Updating kubeconfig..."

aws eks update-kubeconfig \
  --region eu-west-1 \
  --name devops-eks

echo ""
echo "Deploying Helm releases..."

cd ../../../helm

helmfile sync

echo ""
echo "Bootstrap completed successfully."
```
