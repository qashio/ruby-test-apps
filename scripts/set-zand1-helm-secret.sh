#!/usr/bin/env bash
# Store the zand1-token PAT in GitHub Actions secrets for helm-charts GitOps push.
#
# Prerequisites (GitHub → Settings → Developer settings → Fine-grained tokens):
#   Token name: zand1-token
#   Repository access: qashio/helm-charts only
#   Permissions: Contents (Read and write), Metadata (Read)
#
# Usage:
#   export ZAND1_TOKEN='ghp_...'   # paste PAT once in your shell; do not commit
#   ./scripts/set-zand1-helm-secret.sh
#   ./scripts/set-zand1-helm-secret.sh ae-prod ae-uat   # also set per environment

set -euo pipefail

REPO="${GITHUB_REPO:-qashio/ruby-test-apps}"

if [[ -z "${ZAND1_TOKEN:-}" ]]; then
  echo "ERROR: Set ZAND1_TOKEN to your zand1-token PAT value in the environment." >&2
  exit 1
fi

echo "Setting ZAND1_TOKEN and HELM_REPO_TOKEN on ${REPO}..."
gh secret set ZAND1_TOKEN --repo "$REPO" --body "$ZAND1_TOKEN"
gh secret set HELM_REPO_TOKEN --repo "$REPO" --body "$ZAND1_TOKEN"

for env_name in "$@"; do
  echo "Setting secrets on environment: ${env_name}"
  gh secret set ZAND1_TOKEN --repo "$REPO" --env "$env_name" --body "$ZAND1_TOKEN"
  gh secret set HELM_REPO_TOKEN --repo "$REPO" --env "$env_name" --body "$ZAND1_TOKEN"
done

echo "Done."
