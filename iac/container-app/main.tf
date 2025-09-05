resource "azurerm_resource_group" "rg" {
  name     = "streamlit-app-rg"
  location = var.az_location
}

resource "azurerm_log_analytics_workspace" "logs" {
  name                = "streamlit-app-logs"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_container_app_environment" "aca_env" {
  name                       = "streamlit-app-aca-env"
  location                   = azurerm_resource_group.rg.location
  resource_group_name        = azurerm_resource_group.rg.name
  log_analytics_workspace_id = azurerm_log_analytics_workspace.logs.id
}

resource "azurerm_container_app" "aca" {
  name                         = "streamlit-app-aca"
  container_app_environment_id = azurerm_container_app_environment.aca_env.id
  resource_group_name          = azurerm_resource_group.rg.name
  revision_mode                = "Single"

ingress {
    external_enabled = true
    target_port      = 8501
    traffic_weight {
      latest_revision = true
      percentage = 100
    }
  }

  template {
    container {
      name   = "streamlitcontainerapp"
      image  = "${var.aws_public_ecr_repo_uri}:latest"
      cpu    = 0.25
      memory = "0.5Gi"
    }
    
    min_replicas = 0
    max_replicas = 1
  }
}

resource "azuread_application" "azure_app" {
  display_name = "streamlit-aca-deployer"
}

resource "azuread_service_principal" "azure_app_sp" {
  client_id = azuread_application.azure_app.client_id
}

resource "azurerm_role_assignment" "azure_app_rg_role_assignment" {
  scope                = azurerm_resource_group.rg.id
  role_definition_name = "Container Apps Contributor"
  principal_id         = azuread_service_principal.azure_app_sp.object_id
}

# GitHub Actions OIDC federated credential (branch-scoped)
# Subject format options:
#  - Branch:       repo:OWNER/REPO:ref:refs/heads/main
#  - Tag:          repo:OWNER/REPO:ref:refs/tags/v1.2.3
#  - Environment:  repo:OWNER/REPO:environment:prod
resource "azuread_application_federated_identity_credential" "gha_oidc" {
  application_id        = azuread_application.azure_app.id
  display_name          = "github-${var.github_owner}-${var.github_repo}-main"
  audiences             = ["api://AzureADTokenExchange"]
  issuer                = "https://token.actions.githubusercontent.com"
  subject               = "repo:${var.github_owner}/${var.github_repo}:ref:${var.github_ref}"
}

output "APP_AZURE_CLIENT_ID" {
  value       = azuread_application.azure_app.client_id
  description = "Put this into GitHub Secrets"
}