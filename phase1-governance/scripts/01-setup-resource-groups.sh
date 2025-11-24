#!/usr/bin/env bash
set -euo pipefail

# 01-setup-resource-groups.sh
# Creates governance and workload resource groups used in Phase 1.

LOCATION="canadacentral"
RG_GOV="rg-governance-demo"
RG_APP="rg-app-dev-canada"
RG_DENY="rg-deny-test"

echo "Using location: $LOCATION"

echo "Creating governance resource group: $RG_GOV"
az group create \
  --name "$RG_GOV" \
  --location "$LOCATION" \
  >/dev/null

echo "Creating app resource group: $RG_APP"
az group create \
  --name "$RG_APP" \
  --location "$LOCATION" \
  --tags environment=dev owner="mehrnaz" costCenter="LAB" criticality=low \
  >/dev/null

echo "Creating deny-test resource group: $RG_DENY"
az group create \
  --name "$RG_DENY" \
  --location "$LOCATION" \
  >/dev/null

echo "Resource groups created:"
az group list --query "[?name=='$RG_GOV' || name=='$RG_APP' || name=='$RG_DENY'].{name:name, location:location, tags:tags}" -o table
