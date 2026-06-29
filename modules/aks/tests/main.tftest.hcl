mock_provider "azurerm" {}

# Verifica que el cluster se crea con identidad SystemAssigned (requerida para managed identity)
run "uses_system_assigned_identity" {
  variables {
    name                = "aks-test-001"
    location            = "westeurope"
    resource_group_name = "rg-test"
    dns_prefix          = "aks-test"
  }

  assert {
    condition     = azurerm_kubernetes_cluster.this.identity[0].type == "SystemAssigned"
    error_message = "AKS debe usar SystemAssigned identity para managed identity"
  }
}

# Verifica que el VM size por defecto es el correcto
run "default_vm_size" {
  variables {
    name                = "aks-vmsize-test"
    location            = "westeurope"
    resource_group_name = "rg-test"
    dns_prefix          = "aks-test"
  }

  assert {
    condition     = azurerm_kubernetes_cluster.this.default_node_pool[0].vm_size == "Standard_D2s_v3"
    error_message = "VM size por defecto debe ser Standard_D2s_v3"
  }

  assert {
    condition     = azurerm_kubernetes_cluster.this.default_node_pool[0].node_count == 2
    error_message = "Node count por defecto debe ser 2"
  }
}

# Verifica que el autoscaling está desactivado por defecto
run "autoscaling_disabled_by_default" {
  variables {
    name                = "aks-autoscale-test"
    location            = "westeurope"
    resource_group_name = "rg-test"
    dns_prefix          = "aks-test"
  }

  assert {
    condition     = azurerm_kubernetes_cluster.this.default_node_pool[0].auto_scaling_enabled == false
    error_message = "Autoscaling debe estar desactivado por defecto"
  }

  assert {
    condition     = azurerm_kubernetes_cluster.this.default_node_pool[0].min_count == null
    error_message = "min_count debe ser null cuando autoscaling está desactivado"
  }
}

# Verifica que el autoscaling se activa correctamente
run "autoscaling_enabled" {
  variables {
    name                = "aks-autoscale-on"
    location            = "westeurope"
    resource_group_name = "rg-test"
    dns_prefix          = "aks-test"
    enable_auto_scaling = true
    min_count           = 2
    max_count           = 10
  }

  assert {
    condition     = azurerm_kubernetes_cluster.this.default_node_pool[0].auto_scaling_enabled == true
    error_message = "Autoscaling debe estar activado"
  }

  assert {
    condition     = azurerm_kubernetes_cluster.this.default_node_pool[0].min_count == 2
    error_message = "min_count debe ser 2"
  }

  assert {
    condition     = azurerm_kubernetes_cluster.this.default_node_pool[0].max_count == 10
    error_message = "max_count debe ser 10"
  }
}

# Verifica que Azure RBAC está desactivado por defecto (opt-in)
run "azure_rbac_disabled_by_default" {
  variables {
    name                = "aks-rbac-test"
    location            = "westeurope"
    resource_group_name = "rg-test"
    dns_prefix          = "aks-test"
  }

  assert {
    condition     = length(azurerm_kubernetes_cluster.this.azure_active_directory_role_based_access_control) == 0
    error_message = "Azure RBAC debe estar desactivado por defecto"
  }
}

# Verifica que Azure RBAC se activa con admin group (fix: admin_group_object_ids es requerido)
run "azure_rbac_enabled" {
  variables {
    name                   = "aks-rbac-on"
    location               = "westeurope"
    resource_group_name    = "rg-test"
    dns_prefix             = "aks-test"
    enable_azure_rbac      = true
    admin_group_object_ids = ["00000000-0000-0000-0000-000000000001"]
  }

  assert {
    condition     = length(azurerm_kubernetes_cluster.this.azure_active_directory_role_based_access_control) == 1
    error_message = "El bloque RBAC debe crearse cuando enable_azure_rbac=true"
  }

  assert {
    condition     = azurerm_kubernetes_cluster.this.azure_active_directory_role_based_access_control[0].azure_rbac_enabled == true
    error_message = "Azure RBAC debe estar activado"
  }
}
