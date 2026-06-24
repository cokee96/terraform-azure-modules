resource "azurerm_virtual_network" "this" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  address_space       = var.address_space
  tags                = var.tags
}

resource "azurerm_subnet" "this" {
  for_each = { for s in var.subnets : s.name => s }

  name                 = each.value.name
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = each.value.address_prefixes
  service_endpoints    = each.value.service_endpoints

  private_endpoint_network_policies_enabled = each.value.private_endpoint_network_policies_enabled

  dynamic "delegation" {
    for_each = each.value.delegation != null ? [each.value.delegation] : []
    content {
      name = delegation.value.name
      service_delegation {
        name    = delegation.value.service_delegation.name
        actions = delegation.value.service_delegation.actions
      }
    }
  }
}

resource "azurerm_subnet_network_security_group_association" "this" {
  for_each = { for s in var.subnets : s.name => s if s.nsg_id != null }

  subnet_id                 = azurerm_subnet.this[each.key].id
  network_security_group_id = each.value.nsg_id
}

resource "azurerm_subnet_route_table_association" "this" {
  for_each = { for s in var.subnets : s.name => s if s.route_table_id != null }

  subnet_id      = azurerm_subnet.this[each.key].id
  route_table_id = each.value.route_table_id
}
