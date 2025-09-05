terraform {
  required_providers {
    azurerm = {
        source = "hashicorp/azurerm"
        version = "~> 4.41"
    }

    azuread = {
      source = "hashicorp/azuread"
      version = "~> 3.1.0"
    }
  }
}

provider "azurerm" {
    features {}
    subscription_id = var.az_subscription_id
    tenant_id       = var.az_tenant_id
}