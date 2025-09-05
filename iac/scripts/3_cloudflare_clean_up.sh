#!/bin/bash

# load environment variables
source ./.env

# list all DNS records
DNS_RECORDS_RESPONSE=$(curl https://api.cloudflare.com/client/v4/zones/$CLOUDFLARE_ZONE_ID/dns_records \
    -H "X-Auth-Email: $CLOUDFLARE_EMAIL" \
    -H "Authorization: Bearer $CLOUDFLARE_DNS_API_TOKEN")

if [ $USE_ROOT_DOMAIN = "TRUE" ]; then
    # remove TXT validation record from CloudFlare
    VALIDATION_TXT_DNS_RECORD_ID=$(jq -r ".result[] | select(.type == \"TXT\" and .name == \"$DNS_TXT_VALIDATION_RECORD_NAME.$CUSTOM_DOMAIN\") | .id" <<< "$DNS_RECORDS_RESPONSE")

    curl https://api.cloudflare.com/client/v4/zones/$CLOUDFLARE_ZONE_ID/dns_records/$VALIDATION_TXT_DNS_RECORD_ID \
        -X DELETE \
        -H "X-Auth-Email: $CLOUDFLARE_EMAIL" \
        -H "Authorization: Bearer $CLOUDFLARE_DNS_API_TOKEN"

    # remove root domain A record from CloudFlare
    ROOT_DOMAIN_A_DNS_RECORD_ID=$(jq -r ".result[] | select(.type == \"A\" and .name == \"$CUSTOM_DOMAIN\") | .id" <<< "$DNS_RECORDS_RESPONSE")
    
    curl https://api.cloudflare.com/client/v4/zones/$CLOUDFLARE_ZONE_ID/dns_records/$ROOT_DOMAIN_A_DNS_RECORD_ID \
        -X DELETE \
        -H "X-Auth-Email: $CLOUDFLARE_EMAIL" \
        -H "Authorization: Bearer $CLOUDFLARE_DNS_API_TOKEN"
fi

if [ $USE_WWW_SUBDOMAIN = "TRUE" ]; then
    # remove TXT validation record from CloudFlare
    VALIDATION_TXT_DNS_RECORD_ID=$(jq -r ".result[] | select(.type == \"TXT\" and .name == \"$DNS_TXT_VALIDATION_RECORD_NAME.www.$CUSTOM_DOMAIN\") | .id" <<< "$DNS_RECORDS_RESPONSE")

    curl https://api.cloudflare.com/client/v4/zones/$CLOUDFLARE_ZONE_ID/dns_records/$VALIDATION_TXT_DNS_RECORD_ID \
        -X DELETE \
        -H "X-Auth-Email: $CLOUDFLARE_EMAIL" \
        -H "Authorization: Bearer $CLOUDFLARE_DNS_API_TOKEN"

    # remove domain CNAME record from CloudFlare
    WWW_DOMAIN_CNAME_DNS_RECORD_ID=$(jq -r ".result[] | select(.type == \"CNAME\" and .name == \"www.$CUSTOM_DOMAIN\") | .id" <<< "$DNS_RECORDS_RESPONSE")
    
    curl https://api.cloudflare.com/client/v4/zones/$CLOUDFLARE_ZONE_ID/dns_records/$WWW_DOMAIN_CNAME_DNS_RECORD_ID \
        -X DELETE \
        -H "X-Auth-Email: $CLOUDFLARE_EMAIL" \
        -H "Authorization: Bearer $CLOUDFLARE_DNS_API_TOKEN"
fi

if [ $USE_CUSTOM_SUBDOMAIN = "TRUE" ]; then
    # remove TXT validation record from CloudFlare
    VALIDATION_TXT_DNS_RECORD_ID=$(jq -r ".result[] | select(.type == \"TXT\" and .name == \"$DNS_TXT_VALIDATION_RECORD_NAME.$CUSTOM_SUBDOMAIN.$CUSTOM_DOMAIN\") | .id" <<< "$DNS_RECORDS_RESPONSE")

    curl https://api.cloudflare.com/client/v4/zones/$CLOUDFLARE_ZONE_ID/dns_records/$VALIDATION_TXT_DNS_RECORD_ID \
        -X DELETE \
        -H "Authorization: Bearer $CLOUDFLARE_DNS_API_TOKEN" \
        -H "Content-Type: application/json"

    # remove domain CNAME record from CloudFlare
    SUBDOMAIN_DOMAIN_CNAME_DNS_RECORD_ID=$(jq -r ".result[] | select(.type == \"CNAME\" and .name == \"$CUSTOM_SUBDOMAIN.$CUSTOM_DOMAIN\") | .id" <<< "$DNS_RECORDS_RESPONSE")
    
    curl https://api.cloudflare.com/client/v4/zones/$CLOUDFLARE_ZONE_ID/dns_records/$SUBDOMAIN_DOMAIN_CNAME_DNS_RECORD_ID \
        -X DELETE \
        -H "Authorization: Bearer $CLOUDFLARE_DNS_API_TOKEN" \
        -H "Content-Type: application/json"
fi
