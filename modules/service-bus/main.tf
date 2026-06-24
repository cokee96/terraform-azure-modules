resource "azurerm_servicebus_namespace" "this" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = var.sku
  tags                = var.tags
}

resource "azurerm_servicebus_queue" "this" {
  for_each = { for q in var.queues : q.name => q }

  name         = each.value.name
  namespace_id = azurerm_servicebus_namespace.this.id

  partitioning_enabled = lookup(each.value, "partitioning_enabled", false)
}

resource "azurerm_servicebus_topic" "this" {
  for_each = { for t in var.topics : t.name => t }

  name         = each.value.name
  namespace_id = azurerm_servicebus_namespace.this.id
}
