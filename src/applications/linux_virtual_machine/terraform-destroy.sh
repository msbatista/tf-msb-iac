#! /bin/bash

terraform -chdir="$(dirname $(realpath $0))" destroy \
    -var "environment=${ENVIRONMENT}" \
    -var "admin_user=${ADMIN_USER}" \
    -var "admin_password=${ADMIN_PASSWORD}" \
    -var-file="terraform.tfvars"