```bash
#!/bin/bash

set -e

echo "======================================"
echo "Destroying Infrastructure"
echo "======================================"

read -p "Are you sure? (yes/no): " confirm

if [ "$confirm" != "yes" ]; then
  echo "Aborted."
  exit 1
fi

cd terraform/environments/dev

terraform destroy -auto-approve

echo ""
echo "Infrastructure destroyed."
```
