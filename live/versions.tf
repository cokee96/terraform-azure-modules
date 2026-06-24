terraform {
  required_version = ">= 1.3.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.0.0"
    }
  }

  # Descomenta y configura el backend para almacenar el estado en Azure Blob Storage
  # backend "azurerm" {
  #   resource_group_name  = "rg-terraform-state"
  #   storage_account_name = "stterraformstate"
  #   container_name       = "tfstate"
  #   key                  = "{project}-{environment}.tfstate"  # ej. myapp-prod.tfstate
  # }
}

provider "azurerm" {
  features {}
}
