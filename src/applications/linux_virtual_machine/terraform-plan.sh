#! /bin/bash

terraform -chdir="$(dirname $(realpath $0))" validate

terraform -chdir="$(dirname $(realpath $0))" plan \
    -var "environment=${ENVIRONMENT}" \
    -var "admin_user=${ADMIN_USER}" \
    -var "admin_password=${ADMIN_PASSWORD}" \
    -var-file="terraform.tfvars" \
    -out "linux-vm.plan"