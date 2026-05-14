#!/bin/bash
set -e

echo "======================================"
echo "Kubernetes Cluster Validation"
echo "======================================"

echo "Checking nodes..."
kubectl get nodes

echo "Checking namespaces..."
kubectl get ns

echo "Checking pods..."
kubectl get pods -A

echo "Checking services..."
kubectl get svc -A

echo "Checking Helm releases..."
helm list -A

echo "Checking Prometheus..."
kubectl get pods -n monitoring

echo "Validation completed successfully."
