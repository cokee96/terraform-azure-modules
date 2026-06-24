output "id" {
  value       = azurerm_servicebus_namespace.this.id
  description = "Resource ID of the Service Bus namespace."
}

output "name" {
  value       = azurerm_servicebus_namespace.this.name
  description = "Name of the Service Bus namespace."
}

output "endpoint" {
  value       = azurerm_servicebus_namespace.this.endpoint
  description = "Endpoint of the Service Bus namespace."
}

output "primary_connection_string" {
  value       = azurerm_servicebus_namespace.this.default_primary_connection_string
  sensitive   = true
  description = "Primary connection string for the Service Bus namespace."
}

output "queue_ids" {
  value       = { for k, q in azurerm_servicebus_queue.this : k => q.id }
  description = "Map of queue name to resource ID."
}

output "topic_ids" {
  value       = { for k, t in azurerm_servicebus_topic.this : k => t.id }
  description = "Map of topic name to resource ID."
}
