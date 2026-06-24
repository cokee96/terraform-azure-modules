resource "azurerm_mssql_server" "this" {
  name                         = var.server_name
  resource_group_name          = var.resource_group_name
  location                     = var.location
  version                      = "12.0"
  administrator_login          = var.admin_login
  administrator_login_password = var.admin_password
  minimum_tls_version          = "1.2"
  tags                         = var.tags

  dynamic "azuread_administrator" {
    for_each = var.aad_admin != null ? [var.aad_admin] : []
    content {
      login_username = azuread_administrator.value.login_username
      object_id      = azuread_administrator.value.object_id
      tenant_id      = azuread_administrator.value.tenant_id
    }
  }
}

resource "azurerm_mssql_database" "this" {
  name        = var.db_name
  server_id   = azurerm_mssql_server.this.id
  sku_name    = var.db_sku_name
  max_size_gb = var.max_size_gb
  tags        = var.tags
}
