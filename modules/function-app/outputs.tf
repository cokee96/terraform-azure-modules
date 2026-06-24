output "id" {
  value       = azurerm_linux_function_app.this.id
  description = "Resource ID of the Linux Function App."
}

output "name" {
  value       = azurerm_linux_function_app.this.name
  description = "Name of the Linux Function App."
}

output "default_hostname" {
  value       = azurerm_linux_function_app.this.default_hostname
  description = "Default hostname of the Function App."
}

output "principal_id" {
  value       = azurerm_linux_function_app.this.identity[0].principal_id
  description = "Principal ID of the system-assigned managed identity."
}
