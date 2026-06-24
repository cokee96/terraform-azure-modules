locals {
  storage_account_name = var.storage_account_name != null ? var.storage_account_name : "${replace(var.name, "-", "")}sa"
}

resource "azurerm_service_plan" "this" {
  name                = "${var.name}-plan"
  resource_group_name = var.resource_group_name
  location            = var.location
  os_type             = "Linux"
  sku_name            = var.sku_name
  tags                = var.tags
}

resource "azurerm_storage_account" "this" {
  name                     = local.storage_account_name
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  min_tls_version          = "TLS1_2"
  tags                     = var.tags
}

resource "azurerm_linux_function_app" "this" {
  name                       = var.name
  resource_group_name        = var.resource_group_name
  location                   = var.location
  service_plan_id            = azurerm_service_plan.this.id
  storage_account_name       = azurerm_storage_account.this.name
  storage_account_access_key = azurerm_storage_account.this.primary_access_key
  app_settings               = var.app_settings
  tags                       = var.tags

  site_config {
    application_stack {
      python_version = var.runtime.name == "python" ? var.runtime.version : null
      node_version   = var.runtime.name == "node" ? var.runtime.version : null
      java_version   = var.runtime.name == "java" ? var.runtime.version : null
      dotnet_version = var.runtime.name == "dotnet" ? var.runtime.version : null
    }
  }

  identity {
    type = "SystemAssigned"
  }
}
