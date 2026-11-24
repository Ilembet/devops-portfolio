#!/usr/bin/env bash
# Usage: source infra/terraform/env.sh
# Exports short-lived credentials for Terraform (the IAM token lives up to 12 hours)
# and the Object Storage key for the remote state. Requires the yc CLI profile
# pointing at the portfolio folder.

SA_ID="$(yc iam service-account get --name terraform-sa --format json \
  | python3 -c 'import json,sys; print(json.load(sys.stdin)["id"])')"
YC_TOKEN="$(yc iam create-token --impersonate-service-account-id "$SA_ID")"
YC_CLOUD_ID="$(yc config get cloud-id)"
YC_FOLDER_ID="$(yc config get folder-id)"
export YC_TOKEN YC_CLOUD_ID YC_FOLDER_ID

# Static access key for the state bucket; kept outside the repository.
S3_ENV="${HOME}/.config/portfolio/s3.env"
if [ -f "$S3_ENV" ]; then
  # shellcheck source=/dev/null
  . "$S3_ENV"
else
  echo "Warning: ${S3_ENV} not found, the remote state will not work" >&2
fi

echo "Terraform credentials are set for folder ${YC_FOLDER_ID}"
