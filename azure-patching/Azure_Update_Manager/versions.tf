terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.100.0"
    }
    azapi = {
      source  = "azure/azapi"
      version = "1.13.0"
    }
  }
}