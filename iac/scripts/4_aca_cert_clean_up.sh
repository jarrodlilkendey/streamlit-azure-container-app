#!/bin/bash

# load environment variables
source ./.env

# must delete aca bindings before deleting aca certificates
if [ $USE_ROOT_DOMAIN = "TRUE" ]; then
    az containerapp hostname delete \
        --hostname $CUSTOM_DOMAIN \
        -g $AZURE_RESOURCE_GROUP \
        -n $AZURE_CONTAINER_APP_NAME
fi

if [ $USE_WWW_SUBDOMAIN = "TRUE" ]; then
    az containerapp hostname delete \
        --hostname "www.$CUSTOM_DOMAIN" \
        -g $AZURE_RESOURCE_GROUP \
        -n $AZURE_CONTAINER_APP_NAME
fi

if [ $USE_CUSTOM_SUBDOMAIN = "TRUE" ]; then
    az containerapp hostname delete \
        --hostname "$CUSTOM_SUBDOMAIN.$CUSTOM_DOMAIN" \
        -g $AZURE_RESOURCE_GROUP \
        -n $AZURE_CONTAINER_APP_NAME
fi

# delete aca certificates
az containerapp env certificate delete -g $AZURE_RESOURCE_GROUP --name $AZURE_CONTAINER_ENV_NAME --certificate $AZURE_CERTIFICATE_NAME

# remove locally stored PEM and PFX files
rm $PEM_FILE_PATH
rm $PFX_FILE_PATH