```bash
#!/bin/bash

set -e

echo "======================================"
echo "Kubernetes Cluster Validation"
echo "======================================"

echo ""
echo "Checking nodes..."
kubectl get nodes

echo ""
echo "Checking namespaces..."
kubectl get ns

echo ""
echo "Checking pods..."
kubectl get pods -A

echo ""
echo "Checking services..."
kubectl get svc -A

echo ""
echo "Checking ingress..."
kubectl get ingress -A

echo ""
echo "Checking Helm releases..."
helm list -A

echo ""
echo "Checking Prometheus..."
kubectl get pods -n monitoring

echo ""
echo "Checking Trivy Operator..."
kubectl get pods -n trivy-system

echo ""
echo "Validation completed successfully."
```
