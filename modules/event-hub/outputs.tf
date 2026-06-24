output "namespace_id" {
  value       = azurerm_eventhub_namespace.this.id
  description = "Resource ID of the Event Hub namespace."
}

output "namespace_name" {
  value       = azurerm_eventhub_namespace.this.name
  description = "Name of the Event Hub namespace."
}

output "event_hub_ids" {
  value       = { for k, e in azurerm_eventhub.this : k => e.id }
  description = "Map of Event Hub name to resource ID."
}

output "primary_connection_string" {
  value       = azurerm_eventhub_namespace.this.default_primary_connection_string
  sensitive   = true
  description = "Primary connection string for the Event Hub namespace."
}
