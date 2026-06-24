resource "azurerm_eventhub_namespace" "this" {
  name                = var.namespace_name
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = var.sku
  capacity            = var.capacity
  tags                = var.tags
}

resource "azurerm_eventhub" "this" {
  for_each = { for e in var.event_hubs : e.name => e }

  name              = each.value.name
  namespace_id      = azurerm_eventhub_namespace.this.id
  partition_count   = lookup(each.value, "partition_count", 2)
  message_retention = lookup(each.value, "message_retention", 1)
}
