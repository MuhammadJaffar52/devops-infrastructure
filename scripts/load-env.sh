#!/bin/bash

set -e

# =========================================================
# VALIDATE ENVIRONMENT
# =========================================================

if [ -z "$ENVIRONMENT" ]; then
  echo "ERROR: ENVIRONMENT variable not set"
  echo ""
  echo "Example:"
  echo "ENVIRONMENT=dev"
  exit 1
fi

# =========================================================
# LOAD ENV FILE
# =========================================================

ENV_FILE="configs/${ENVIRONMENT}.env"

if [ ! -f "$ENV_FILE" ]; then
  echo "ERROR: Environment file not found: $ENV_FILE"
  exit 1
fi

echo "===================================="
echo "Loading Environment Config"
echo "===================================="

echo "Environment: $ENVIRONMENT"
echo "Config File: $ENV_FILE"

echo "===================================="

export $(grep -v '^#' $ENV_FILE | xargs)
