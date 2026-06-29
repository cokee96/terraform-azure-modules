mock_provider "azurerm" {}

# Verifica que el nombre y la región se pasan correctamente al recurso
run "name_and_location_match_inputs" {
  variables {
    name     = "rg-test-westeu-001"
    location = "westeurope"
    tags     = { environment = "test" }
  }

  assert {
    condition     = azurerm_resource_group.this.name == "rg-test-westeu-001"
    error_message = "El nombre del resource group no coincide con el input"
  }

  assert {
    condition     = azurerm_resource_group.this.location == "westeurope"
    error_message = "La región no coincide con el input"
  }
}

# Verifica que los outputs del módulo devuelven los valores correctos
run "outputs_match_inputs" {
  variables {
    name     = "rg-outputs-test"
    location = "eastus"
  }

  assert {
    condition     = output.name == "rg-outputs-test"
    error_message = "Output 'name' no devuelve el nombre correcto"
  }

  assert {
    condition     = output.location == "eastus"
    error_message = "Output 'location' no devuelve la región correcta"
  }
}

# Verifica que los tags se aplican correctamente
run "tags_are_applied" {
  variables {
    name     = "rg-tags-test"
    location = "westeurope"
    tags = {
      environment = "production"
      project     = "platform"
      owner       = "devops"
    }
  }

  assert {
    condition     = azurerm_resource_group.this.tags["environment"] == "production"
    error_message = "Tag 'environment' no tiene el valor correcto"
  }

  assert {
    condition     = length(azurerm_resource_group.this.tags) == 3
    error_message = "Número de tags incorrecto"
  }
}

# Verifica que el módulo funciona sin tags (valor por defecto = {})
run "works_without_tags" {
  variables {
    name     = "rg-notags-test"
    location = "northeurope"
  }

  assert {
    condition     = length(azurerm_resource_group.this.tags) == 0
    error_message = "Tags debería ser un mapa vacío por defecto"
  }
}
