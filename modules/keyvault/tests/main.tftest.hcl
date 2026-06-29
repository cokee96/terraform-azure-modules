mock_provider "azurerm" {
  mock_data "azurerm_client_config" {
    defaults = {
      tenant_id = "00000000-0000-0000-0000-000000000000"
    }
  }
}

# Verifica que purge protection está activado por defecto (no se puede desactivar en prod)
run "purge_protection_enabled_by_default" {
  variables {
    name                = "kv-test-001"
    location            = "westeurope"
    resource_group_name = "rg-test"
  }

  assert {
    condition     = azurerm_key_vault.this.purge_protection_enabled == true
    error_message = "Purge protection debe estar activado por defecto"
  }
}

# Verifica que soft delete retention es 90 días por defecto
run "soft_delete_90_days_by_default" {
  variables {
    name                = "kv-softdelete-test"
    location            = "westeurope"
    resource_group_name = "rg-test"
  }

  assert {
    condition     = azurerm_key_vault.this.soft_delete_retention_days == 90
    error_message = "Soft delete debe ser 90 días por defecto"
  }
}

# Verifica que el SKU por defecto es standard
run "default_sku_is_standard" {
  variables {
    name                = "kv-sku-test"
    location            = "westeurope"
    resource_group_name = "rg-test"
  }

  assert {
    condition     = azurerm_key_vault.this.sku_name == "standard"
    error_message = "SKU por defecto debe ser standard"
  }
}

# Verifica que se puede usar SKU premium
run "premium_sku" {
  variables {
    name                = "kv-premium-test"
    location            = "westeurope"
    resource_group_name = "rg-test"
    sku_name            = "premium"
  }

  assert {
    condition     = azurerm_key_vault.this.sku_name == "premium"
    error_message = "SKU debe ser premium cuando se especifica"
  }
}

# Verifica que la validación rechaza SKUs inválidos
run "invalid_sku_fails_validation" {
  command = plan

  variables {
    name                = "kv-invalid-test"
    location            = "westeurope"
    resource_group_name = "rg-test"
    sku_name            = "basic"
  }

  expect_failures = [var.sku_name]
}

# Verifica que RBAC authorization está activado por defecto (más seguro que access policies)
run "rbac_enabled_by_default" {
  variables {
    name                = "kv-rbac-test"
    location            = "westeurope"
    resource_group_name = "rg-test"
  }

  assert {
    condition     = azurerm_key_vault.this.rbac_authorization_enabled == true
    error_message = "RBAC debe estar activado por defecto"
  }
}
