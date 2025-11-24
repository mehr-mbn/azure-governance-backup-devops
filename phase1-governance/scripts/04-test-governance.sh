#!/usr/bin/env bash
set -euo pipefail

# 04-test-governance.sh
# This file documents the key test flows used in Phase 1:
# 1) Auto-tagging with append policy at subscription scope
# 2) Hard enforcement with deny policy at resource group scope

# NOTE:
# Run commands step-by-step instead of executing the entire script in one go.
# It is intended as documentation + copy/paste helper.

echo "This script is a documentation helper. Open it and run the commands section by section."
exit 0

# ---------------------------------------------------------------------------
# SECTION 1: Test auto-tagging (append) on a storage account
# ---------------------------------------------------------------------------

# Assumes:
# - enforce-standard-tags policy is assigned at subscription scope
# - rg-app-dev-canada exists

RG_APP="rg-app-dev-canada"
RAND=$RANDOM
ST_NAME="stappendtest${RAND}"

echo "Creating storage account WITHOUT tags (append policy should auto-tag)..."

az storage account create \
  --name "$ST_NAME" \
  --resource-group "$RG_APP" \
  --location canadacentral \
  --sku Standard_LRS

echo "Showing tags on the created storage account:"
az resource show \
  --resource-group "$RG_APP" \
  --name "$ST_NAME" \
  --resource-type "Microsoft.Storage/storageAccounts" \
  --query tags

# Expected: tags environment / owner / costCenter / criticality are present.


# ---------------------------------------------------------------------------
# SECTION 2: Enable deny policy on rg-deny-test
# ---------------------------------------------------------------------------

SUB_ID=$(az account show --query id -o tsv)
RG_DENY="rg-deny-test"
DENY_ASSIGN_NAME="deny-missing-standard-tags-test"
DENY_POLICY_NAME="deny-missing-standard-tags"

echo "Assigning deny policy to resource group: $RG_DENY"

az policy assignment create \
  --name "$DENY_ASSIGN_NAME" \
  --policy "$DENY_POLICY_NAME" \
  --scope "/subscriptions/$SUB_ID/resourceGroups/$RG_DENY"

az policy assignment list \
  --scope "/subscriptions/$SUB_ID/resourceGroups/$RG_DENY" \
  -o table

# ---------------------------------------------------------------------------
# SECTION 3: Test deny behavior (after disabling append, optional flow)
# ---------------------------------------------------------------------------

# If you want to see pure deny behavior without append 'fixing' the tags,
# temporarily remove the append assignment at subscription level:

# SUB_ID=$(az account show --query id -o tsv)
# az policy assignment delete \
#   --name enforce-standard-tags-assignment \
#   --scope "/subscriptions/$SUB_ID"

# Then test in rg-deny-test:

RG_DENY="rg-deny-test"
RAND=$RANDOM
ST_NAME_DENY="stdenytest${RAND}"

echo "Trying to create storage account WITHOUT tags in $RG_DENY (deny should block it)..."

az storage account create \
  --name "$ST_NAME_DENY" \
  --resource-group "$RG_DENY" \
  --location canadacentral \
  --sku Standard_LRS

# Expected: RequestDisallowedByPolicy error.

# Now create the same type of resource WITH tags (should succeed):

RAND=$RANDOM
ST_NAME_DENY_OK="stdenytestok${RAND}"

echo "Creating storage account WITH required tags in $RG_DENY (should succeed)..."

az storage account create \
  --name "$ST_NAME_DENY_OK" \
  --resource-group "$RG_DENY" \
  --location canadacentral \
  --sku Standard_LRS \
  --tags environment=dev owner="mehrnaz" costCenter="LAB" criticality=low

echo "Showing tags on the allowed storage account:"
az resource show \
  --resource-group "$RG_DENY" \
  --name "$ST_NAME_DENY_OK" \
  --resource-type "Microsoft.Storage/storageAccounts" \
  --query tags
