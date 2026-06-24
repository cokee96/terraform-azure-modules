resource "azurerm_service_plan" "this" {
  name                = "${var.name}-plan"
  resource_group_name = var.resource_group_name
  location            = var.location
  os_type             = "Linux"
  sku_name            = var.sku_name
  tags                = var.tags
}

resource "azurerm_linux_web_app" "this" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  service_plan_id     = azurerm_service_plan.this.id
  https_only          = true
  app_settings        = var.app_settings
  tags                = var.tags

  site_config {
    application_stack {
      node_version = var.linux_fx_version != null ? (
        length(regexall("^NODE\\|", var.linux_fx_version)) > 0 ? trimprefix(var.linux_fx_version, "NODE|") : null
      ) : null
      python_version = var.linux_fx_version != null ? (
        length(regexall("^PYTHON\\|", var.linux_fx_version)) > 0 ? trimprefix(var.linux_fx_version, "PYTHON|") : null
      ) : null
      dotnet_version = var.linux_fx_version != null ? (
        length(regexall("^DOTNETCORE\\|", var.linux_fx_version)) > 0 ? trimprefix(var.linux_fx_version, "DOTNETCORE|") : null
      ) : null
      php_version = var.linux_fx_version != null ? (
        length(regexall("^PHP\\|", var.linux_fx_version)) > 0 ? trimprefix(var.linux_fx_version, "PHP|") : null
      ) : null
    }
  }

  identity {
    type = "SystemAssigned"
  }
}
