#!/usr/bin/env bash
set -euo pipefail

# 03-create-deny-policy.sh
# Creates the deny policy definition for missing standard tags.
# Assignment is done at resource group scope (e.g., rg-deny-test) manually or in tests.

POLICY_NAME="deny-missing-standard-tags"
RULES_FILE="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/policy-deny-missing-tags.json"

echo "Using rules file: $RULES_FILE"

echo "Creating policy definition: $POLICY_NAME"
az policy definition create \
  --name "$POLICY_NAME" \
  --display-name "Deny resources without standard tags" \
  --description "Denies deployments when required tags (environment, owner, costCenter, criticality) are missing." \
  --rules "$RULES_FILE" \
  --mode Indexed

echo "Policy definition created:"
az policy definition show --name "$POLICY_NAME" --query "{name:name, id:id, displayName:properties.displayName}" -o json
