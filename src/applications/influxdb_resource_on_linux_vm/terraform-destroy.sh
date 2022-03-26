#! /bin/bash

terraform -chdir="$(dirname $(realpath $0))" destroy \
    -var "environment=${ENVIRONMENT}" \
    -var-file="terraform.tfvars"