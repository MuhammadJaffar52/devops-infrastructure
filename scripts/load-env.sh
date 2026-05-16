
#!/bin/sh

set -e

if [ -z "$ENVIRONMENT" ]; then

    echo ""
    echo "ERROR: ENVIRONMENT variable not set"
    echo ""
    echo "Example:"
    echo "ENVIRONMENT=dev"
    echo ""

    exit 1
fi

ENV_FILE="configs/${ENVIRONMENT}.env"

if [ ! -f "$ENV_FILE" ]; then

    echo ""
    echo "ERROR: Environment file not found: $ENV_FILE"
    echo ""

    exit 1
fi

echo ""
echo "======================================"
echo " Loading Environment Configuration"
echo "======================================"
echo "Environment : $ENVIRONMENT"
echo "Config File : $ENV_FILE"
echo "======================================"

set -a
. "$ENV_FILE"
set +a

echo ""
echo "Configuration Loaded Successfully"
echo ""

