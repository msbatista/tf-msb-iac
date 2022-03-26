#! /bin/bash

ENVIRONMENT=dev 

terraform -chdir="$(dirname $(realpath $0))" validate

terraform -chdir="$(dirname $(realpath $0))" plan \
    -var "environment=${ENVIRONMENT}" \
    -var-file="terraform.tfvars" \
    -out "linux-vm-influxdb.plan"