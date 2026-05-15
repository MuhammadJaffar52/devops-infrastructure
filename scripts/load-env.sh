#!/bin/bash

# ============================================================
# DEVOPS INFRASTRUCTURE PLATFORM
# ENVIRONMENT CONFIG LOADER
# ============================================================
#
# PURPOSE:
# Centralized environment configuration loader.
#
# FEATURES:
# - Dynamic environment loading
# - Safe variable exporting
# - Multi-environment support
# - Production-grade validation
# - Reusable globally
#
# ============================================================

set -e

# ============================================================
# VALIDATE ENVIRONMENT VARIABLE
# ============================================================

if [ -z "$ENVIRONMENT" ]; then
  echo ""
  echo "ERROR: ENVIRONMENT variable not set"
  echo ""
  echo "Example:"
  echo "ENVIRONMENT=dev"
  echo ""
  exit 1
fi

# ============================================================
# BUILD CONFIG FILE PATH
# ============================================================

ENV_FILE="configs/${ENVIRONMENT}.env"

# ============================================================
# VALIDATE CONFIG FILE
# ============================================================

if [ ! -f "$ENV_FILE" ]; then
  echo ""
  echo "ERROR: Environment file not found"
  echo ""
  echo "Missing File:"
  echo "$ENV_FILE"
  echo ""
  exit 1
fi

# ============================================================
# HEADER
# ============================================================

echo ""
echo "======================================"
echo " Loading Environment Configuration"
echo "======================================"

echo "Environment : $ENVIRONMENT"
echo "Config File : $ENV_FILE"

echo "======================================"

# ============================================================
# SAFE ENVIRONMENT VARIABLE EXPORT
# ============================================================
#
# WHY THIS METHOD?
#
# OLD:
# export $(grep -v '^#' $ENV_FILE | xargs)
#
# PROBLEMS:
# - breaks with spaces
# - breaks with special characters
# - unsafe parsing
#
# NEW:
# set -a
# source file
# set +a
#
# BENEFITS:
# - safer
# - production-grade
# - shell-native
# - handles quotes/spaces correctly
#
# ============================================================

set -a
source "$ENV_FILE"
set +a

# ============================================================
# SUCCESS MESSAGE
# ============================================================

echo ""
echo "Configuration Loaded Successfully"

echo ""