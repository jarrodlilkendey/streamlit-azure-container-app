#!/bin/bash

# dependencies
# (1) domain has been added to cloudflare
# (2) origin server CA certificate has been created in CloudFlare with the .key file saved locally
# (3) .env created with all values populated as per .env.template
# (4) Azure Container App and Azure Container App Environment have been provisioned

# load environment variables
source ./.env

# use CloudFlare API to get the origin CA certificate
RESPONSE=$(curl https://api.cloudflare.com/client/v4/certificates?zone_id=$CLOUDFLARE_ZONE_ID \
    -H "X-Auth-Email: $CLOUDFLARE_EMAIL" \
    -H "Authorization: Bearer $CLOUDFLARE_DNS_API_TOKEN")

# Write to PEM file
CERTIFICATE=$(echo "$RESPONSE" | jq -r '.result[0].certificate' | sed 's/\\n/\n/g')
echo "$CERTIFICATE" > $PEM_FILE_PATH

# use OpenSSL CLI to convert certificate from PEM to PFX format
openssl pkcs12 -inkey $CLOUDFLARE_PRIVATE_KEY_FILE_PATH -in $PEM_FILE_PATH -export -out $PFX_FILE_PATH -passout pass:$CLOUDFLARE_PFX_PASSWORD

# use Azure CLI to upload certificate in PFX format into the Azure Container App Environment
az containerapp env certificate upload \
  --name $AZURE_CONTAINER_ENV_NAME \
  --resource-group $AZURE_RESOURCE_GROUP \
  --certificate-file $PFX_FILE_PATH \
  --certificate-name $AZURE_CERTIFICATE_NAME \
  --password $CLOUDFLARE_PFX_PASSWORD \
  --query id -o tsv

# use Azure CLI to obtain the DNS validation records to use in CloudFlare

# get the Azure Container App domain verification ID to use in the TXT record
VALIDATION_RECORD=$(az containerapp env show -n $AZURE_CONTAINER_ENV_NAME -g $AZURE_RESOURCE_GROUP --query properties.customDomainConfiguration.customDomainVerificationId -o tsv)

# CloudFlare requires the content for the TXT record to be within quotes
WRAPPED_VALIDATION_RECORD="\\\"$VALIDATION_RECORD\\\""

# get the static IP from the Azure Container App environment to use in the A record
STATIC_IP=$(az containerapp env show -n $AZURE_CONTAINER_ENV_NAME -g $AZURE_RESOURCE_GROUP --query properties.staticIp -o tsv)

# get the hostname from the Azure Container App environment to use in the CNAME record
AZURE_HOST_NAME=$(az containerapp env show -n $AZURE_CONTAINER_ENV_NAME -g $AZURE_RESOURCE_GROUP --query properties.defaultDomain -o tsv)

# use CloudFlare API to set DNS validation records on the domain
if [ $USE_ROOT_DOMAIN = "TRUE" ]; then
  curl -X POST https://api.cloudflare.com/client/v4/zones/$CLOUDFLARE_ZONE_ID/dns_records \
      -H 'Content-Type: application/json' \
      -H "Authorization: Bearer $CLOUDFLARE_DNS_API_TOKEN" \
      -H "X-Auth-Email: $CLOUDFLARE_EMAIL" \
      -d "{
        \"type\": \"TXT\",
        \"name\": \"$DNS_TXT_VALIDATION_RECORD_NAME\",
        \"content\": \"$WRAPPED_VALIDATION_RECORD\",
        \"ttl\": 120,
        \"comment\": \"Domain verification record\",
        \"proxied\": false
      }"
fi

if [ $USE_WWW_SUBDOMAIN = "TRUE" ]; then
  curl -X POST https://api.cloudflare.com/client/v4/zones/$CLOUDFLARE_ZONE_ID/dns_records \
      -H 'Content-Type: application/json' \
      -H "Authorization: Bearer $CLOUDFLARE_DNS_API_TOKEN" \
      -H "X-Auth-Email: $CLOUDFLARE_EMAIL" \
      -d "{
        \"type\": \"TXT\",
        \"name\": \"$DNS_TXT_VALIDATION_RECORD_NAME.www\",
        \"content\": \"$WRAPPED_VALIDATION_RECORD\",
        \"ttl\": 120,
        \"comment\": \"Domain verification record\",
        \"proxied\": false
      }"
fi

if [ $USE_CUSTOM_SUBDOMAIN = "TRUE" ]; then
  curl -X POST https://api.cloudflare.com/client/v4/zones/$CLOUDFLARE_ZONE_ID/dns_records \
      -H 'Content-Type: application/json' \
      -H "Authorization: Bearer $CLOUDFLARE_DNS_API_TOKEN" \
      -H "X-Auth-Email: $CLOUDFLARE_EMAIL" \
      -d "{
        \"type\": \"TXT\",
        \"name\": \"$DNS_TXT_VALIDATION_RECORD_NAME.$CUSTOM_SUBDOMAIN\",
        \"content\": \"$WRAPPED_VALIDATION_RECORD\",
        \"ttl\": 120,
        \"comment\": \"Domain verification record\",
        \"proxied\": false
      }"
fi

# use CloudFlare API to update DNS records to point the domain's root A record to the Azure public IP
if [ $USE_ROOT_DOMAIN = "TRUE" ]; then
  curl -X POST https://api.cloudflare.com/client/v4/zones/$CLOUDFLARE_ZONE_ID/dns_records \
      -H 'Content-Type: application/json' \
      -H "Authorization: Bearer $CLOUDFLARE_DNS_API_TOKEN" \
      -H "X-Auth-Email: $CLOUDFLARE_EMAIL" \
      -d "{
        \"type\": \"A\",
        \"name\": \"@\",
        \"content\": \"$STATIC_IP\",
        \"ttl\": 3600,
        \"comment\": \"Domain A record\",
        \"proxied\": true
      }"
fi

if [ $USE_WWW_SUBDOMAIN = "TRUE" ]; then
  curl -X POST https://api.cloudflare.com/client/v4/zones/$CLOUDFLARE_ZONE_ID/dns_records \
      -H 'Content-Type: application/json' \
      -H "Authorization: Bearer $CLOUDFLARE_DNS_API_TOKEN" \
      -H "X-Auth-Email: $CLOUDFLARE_EMAIL" \
      -d "{
        \"type\": \"CNAME\",
        \"name\": \"www\",
        \"content\": \"$AZURE_CONTAINER_APP_NAME.$AZURE_HOST_NAME\",
        \"ttl\": 3600,
        \"comment\": \"WWW CNAME record\",
        \"proxied\": true
      }"
fi

if [ $USE_CUSTOM_SUBDOMAIN = "TRUE" ]; then
  curl -X POST https://api.cloudflare.com/client/v4/zones/$CLOUDFLARE_ZONE_ID/dns_records \
      -H 'Content-Type: application/json' \
      -H "Authorization: Bearer $CLOUDFLARE_DNS_API_TOKEN" \
      -H "X-Auth-Email: $CLOUDFLARE_EMAIL" \
      -d "{
        \"type\": \"CNAME\",
        \"name\": \"$CUSTOM_SUBDOMAIN\",
        \"content\": \"$AZURE_CONTAINER_APP_NAME.$AZURE_HOST_NAME\",
        \"ttl\": 3600,
        \"comment\": \"$CUSTOM_SUBDOMAIN CNAME record\",
        \"proxied\": true
      }"
fi