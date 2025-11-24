#!/usr/bin/env bash
set -euo pipefail

# 02-create-append-policy.sh
# Creates and assigns the append policy for standard tags at subscription scope.

POLICY_NAME="enforce-standard-tags"
ASSIGNMENT_NAME="enforce-standard-tags-assignment"
RULES_FILE="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/policy-enforce-tags.json"

echo "Using rules file: $RULES_FILE"

SUB_ID=$(az account show --query id -o tsv)
SCOPE="/subscriptions/$SUB_ID"

echo "Creating policy definition: $POLICY_NAME"
az policy definition create \
  --name "$POLICY_NAME" \
  --display-name "Enforce standard tags on all resources (append)" \
  --description "Automatically appends standard tags: environment, owner, costCenter, criticality." \
  --rules "$RULES_FILE" \
  --mode Indexed

echo "Assigning policy at subscription scope: $SCOPE"
az policy assignment create \
  --name "$ASSIGNMENT_NAME" \
  --policy "$POLICY_NAME" \
  --scope "$SCOPE"

echo "Current policy assignments at subscription:"
az policy assignment list --scope "$SCOPE" -o table
