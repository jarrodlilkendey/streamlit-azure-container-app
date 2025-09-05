## Local Development Instructions

```
# set up virtual environment

# create virtual environment
python -m venv .venv

# Windows command prompt
.venv\Scripts\activate

# Windows PowerShell

.venv\Scripts\Activate.ps1

# macOS and Linux

source .venv/bin/activate

# install streamlit
pip3 install -r requirements.txt

# run the app
streamlit run app.py

# clean up venv
deactivate
```

## Docker Instructions

```
docker build -t streamlit .
docker run -p 8501:8501 streamlit
```

## Cloud Infra

### Provision Infra

```
aws configure
cd iac/repo
terraform init
terraform apply -var-file="dev.tfvars"

# follow deployment instructions

az login
cd ../container-app
terraform init
terraform apply -var-file="dev.tfvars"
```

### Clean Up Infra

```
# inside iac/container-app
terraform destroy -var-file="dev.tfvars"
cd ../repo
terraform destroy -var-file="dev.tfvars"
```

### Local Test of GitHub Actions Workflow

```
act --secret-file .github/workflows/deploy.secrets
```

### Creating Cloud Credentials

This is now taken care of by Terraform.

### CloudFlare and Azure Container App Custom Domain Setup

1. Create DNS records in CloudFlare
1. Generate an Origin Certificate in Cloudflare
1. Export PEM key+cert
1. Convert to PFX
1. Upload to ACA
1. Bind custom domain for root and www
1. Set SSL/TLS → “Full (strict)” in CloudFlare
1. Enable Always Use HTTPS - https://developers.cloudflare.com/ssl/edge-certificates/additional-options/always-use-https/

```
Subdomain: CNAME → APP_FQDN and TXT asuid.<sub> → ASUID.
Apex: A → ENV_IP and TXT asuid → ASUID.
```

```
# Convert PEM to PFX
openssl pkcs12 -export -out cloudflare.pfx -inkey cloudflare.key -in cloudflare.pem -passout pass:changeit

# Upload to the ACA environment
az containerapp env certificate upload \
  -g $RG --name $ENV \
  --certificate-file cloudflare.pfx \
  --password changeit \
  --certificate-name example-com-origin

# Bind to your hostname
az containerapp hostname bind \
  -g $RG -n $APP --environment $ENV \
  --hostname www.example.com \
  --certificate example-com-origin \
  --validation-method CNAME
```
