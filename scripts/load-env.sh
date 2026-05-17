#!/bin/sh

set -eu

########################################
# Validate ENVIRONMENT Variable
########################################

if [ -z "${ENVIRONMENT:-}" ]; then

    echo ""
    echo "ERROR: ENVIRONMENT variable is not set"
    echo ""
    echo "Usage:"
    echo "ENVIRONMENT=dev"
    echo ""

    exit 1
fi

########################################
# Environment File
########################################

ENV_FILE="configs/${ENVIRONMENT}.env"

if [ ! -f "$ENV_FILE" ]; then

    echo ""
    echo "ERROR: Environment file not found"
    echo "File: $ENV_FILE"
    echo ""

    exit 1
fi

########################################
# Load Environment Variables
########################################

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

########################################
# Required Variables Validation
########################################

REQUIRED_VARS="
AWS_REGION
APP_NAME
APP_ECR_REPO
APP_DEPLOYMENT
APP_CONTAINER
APP_DOCKER_CONTEXT
APP_DOCKERFILE
APP_K8S_PATH
APP_NAMESPACE
"

validate_variable() {

    VAR_NAME="$1"

    VAR_VALUE=$(eval echo "\${$VAR_NAME:-}")

    if [ -z "$VAR_VALUE" ]; then

        echo ""
        echo "ERROR: Required variable missing"
        echo "Variable: $VAR_NAME"
        echo "Environment: $ENVIRONMENT"
        echo ""

        exit 1
    fi
}

for VAR in $REQUIRED_VARS; do
    validate_variable "$VAR"
done

########################################
# Export Common Runtime Variables
########################################

export ENVIRONMENT
export AWS_REGION
export APP_NAME
export APP_ECR_REPO
export APP_DEPLOYMENT
export APP_CONTAINER
export APP_DOCKER_CONTEXT
export APP_DOCKERFILE
export APP_K8S_PATH
export APP_NAMESPACE

########################################
# Configuration Summary
########################################

echo ""
echo "Configuration Loaded Successfully"
echo ""

echo "Application Configuration"
echo "--------------------------------------"
echo "APP_NAME           = $APP_NAME"
echo "APP_ECR_REPO       = $APP_ECR_REPO"
echo "APP_DEPLOYMENT     = $APP_DEPLOYMENT"
echo "APP_CONTAINER      = $APP_CONTAINER"
echo "APP_DOCKER_CONTEXT = $APP_DOCKER_CONTEXT"
echo "APP_DOCKERFILE     = $APP_DOCKERFILE"
echo "APP_K8S_PATH       = $APP_K8S_PATH"
echo "APP_NAMESPACE      = $APP_NAMESPACE"
echo "AWS_REGION         = $AWS_REGION"
echo ""