#! /bin/bash

az keyvault certificate create \
    --vault-name $KEYVAULT_NAME \
    --name influxdb-self-signed-certificate \
    --policy "$(az keyvault certificate get-default-policy)"