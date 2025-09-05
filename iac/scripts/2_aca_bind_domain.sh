#!/bin/bash

# dependencies
# (1) certificates have been uploaded to azure container app

# load environment variables
source ./.env

# bind custom domain
if [ $USE_ROOT_DOMAIN = "TRUE" ]; then
    az containerapp hostname bind \
        --hostname $CUSTOM_DOMAIN \
        -g $AZURE_RESOURCE_GROUP \
        -n $AZURE_CONTAINER_APP_NAME \
        --environment $AZURE_CONTAINER_ENV_NAME \
        --certificate $AZURE_CERTIFICATE_NAME \
        --validation-method HTTP
fi

if [ $USE_WWW_SUBDOMAIN = "TRUE" ]; then
    az containerapp hostname bind \
        --hostname "www.$CUSTOM_DOMAIN" \
        -g $AZURE_RESOURCE_GROUP \
        -n $AZURE_CONTAINER_APP_NAME \
        --environment $AZURE_CONTAINER_ENV_NAME \
        --certificate $AZURE_CERTIFICATE_NAME \
        --validation-method HTTP
fi

if [ $USE_CUSTOM_SUBDOMAIN = "TRUE" ]; then
    az containerapp hostname bind \
        --hostname "$CUSTOM_SUBDOMAIN.$CUSTOM_DOMAIN" \
        -g $AZURE_RESOURCE_GROUP \
        -n $AZURE_CONTAINER_APP_NAME \
        --environment $AZURE_CONTAINER_ENV_NAME \
        --certificate $AZURE_CERTIFICATE_NAME \
        --validation-method HTTP
fi