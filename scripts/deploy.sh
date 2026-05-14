```bash
#!/bin/bash

set -e

echo "======================================"
echo "Deploying Applications"
echo "======================================"

kubectl apply -f k8s/base/

kubectl apply -f k8s/apps/backend/
kubectl apply -f k8s/apps/frontend/
kubectl apply -f k8s/apps/mongodb/

echo ""
echo "Deployment completed."
```
