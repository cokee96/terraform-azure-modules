mock_provider "azurerm" {}

# Verifica configuración básica de la VNet
run "vnet_basic_config" {
  variables {
    name                = "vnet-test-001"
    resource_group_name = "rg-test"
    location            = "westeurope"
    address_space       = ["10.0.0.0/16"]
  }

  assert {
    condition     = azurerm_virtual_network.this.name == "vnet-test-001"
    error_message = "Nombre de la VNet incorrecto"
  }

  assert {
    condition     = contains(tolist(azurerm_virtual_network.this.address_space), "10.0.0.0/16")
    error_message = "Address space incorrecto"
  }

  assert {
    condition     = azurerm_virtual_network.this.location == "westeurope"
    error_message = "Región incorrecta"
  }
}

# Verifica que se crean subnets correctamente
run "creates_subnets" {
  variables {
    name                = "vnet-subnets-test"
    resource_group_name = "rg-test"
    location            = "westeurope"
    address_space       = ["10.1.0.0/16"]
    subnets = [
      {
        name             = "snet-app"
        address_prefixes = ["10.1.1.0/24"]
      },
      {
        name             = "snet-db"
        address_prefixes = ["10.1.2.0/24"]
      },
    ]
  }

  assert {
    condition     = length(azurerm_subnet.this) == 2
    error_message = "Deberían crearse 2 subnets"
  }

  assert {
    condition     = azurerm_subnet.this["snet-app"].address_prefixes[0] == "10.1.1.0/24"
    error_message = "Prefijo de snet-app incorrecto"
  }

  assert {
    condition     = azurerm_subnet.this["snet-db"].address_prefixes[0] == "10.1.2.0/24"
    error_message = "Prefijo de snet-db incorrecto"
  }
}

# Verifica que funciona sin subnets
run "works_without_subnets" {
  variables {
    name                = "vnet-empty-test"
    resource_group_name = "rg-test"
    location            = "northeurope"
    address_space       = ["172.16.0.0/12"]
  }

  assert {
    condition     = length(azurerm_subnet.this) == 0
    error_message = "No deberían crearse subnets si no se especifican"
  }
}

# Verifica multiple address spaces
run "multiple_address_spaces" {
  variables {
    name                = "vnet-multi-test"
    resource_group_name = "rg-test"
    location            = "westeurope"
    address_space       = ["10.0.0.0/16", "192.168.0.0/24"]
  }

  assert {
    condition     = contains(tolist(azurerm_virtual_network.this.address_space), "10.0.0.0/16") && contains(tolist(azurerm_virtual_network.this.address_space), "192.168.0.0/24")
    error_message = "Deberían configurarse los 2 address spaces especificados"
  }
}
