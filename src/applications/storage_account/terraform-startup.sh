#! /bin/bash

terraform -chdir="$(dirname $(realpath $0))" init \
    -backend-config="container_name=${CONTAINER_NAME}" \
    -backend-config="key=iac/apps/storage_account/${ENVIRONMENT}.terraform.tfstate" \
    -backend-config="storage_account_name=${STORAGE_ACCOUNT_NAME}" \
    -backend-config="access_key=${ACCESS_KEY}" \
    -reconfigure

terraform validate

tflint --init