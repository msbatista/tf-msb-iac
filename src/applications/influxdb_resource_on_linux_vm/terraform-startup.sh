#! /bin/bash

terraform -chdir="$(dirname $(realpath $0))" init -upgrade \
  -backend-config="storage_account_name=$TF_STATE_BLOB_ACCOUNT_NAME" \
  -backend-config="container_name=$TF_STATE_BLOB_CONTAINER_NAME" \
  -backend-config="key=tfstate/servers/$ENVIRONMENT.influxdb.tfstate" \
  -backend-config="access_key=$TF_STATE_BLOB_SAS_TOKEN" \
  -reconfigure

terraform validate
