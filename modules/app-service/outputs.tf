output "id" {
  value       = azurerm_linux_web_app.this.id
  description = "Resource ID of the Linux Web App."
}

output "name" {
  value       = azurerm_linux_web_app.this.name
  description = "Name of the Linux Web App."
}

output "default_hostname" {
  value       = azurerm_linux_web_app.this.default_hostname
  description = "Default hostname of the Web App."
}

output "identity_principal_id" {
  value       = azurerm_linux_web_app.this.identity[0].principal_id
  description = "Principal ID of the system-assigned managed identity."
}

output "service_plan_id" {
  value       = azurerm_service_plan.this.id
  description = "Resource ID of the App Service Plan."
}
