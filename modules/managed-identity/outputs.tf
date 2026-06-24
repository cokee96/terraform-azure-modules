output "id" {
  value       = azurerm_user_assigned_identity.this.id
  description = "Resource ID of the user-assigned managed identity."
}

output "name" {
  value       = azurerm_user_assigned_identity.this.name
  description = "Name of the user-assigned managed identity."
}

output "principal_id" {
  value       = azurerm_user_assigned_identity.this.principal_id
  description = "Service principal ID of the managed identity (used for role assignments)."
}

output "client_id" {
  value       = azurerm_user_assigned_identity.this.client_id
  description = "Client ID of the managed identity."
}

output "tenant_id" {
  value       = azurerm_user_assigned_identity.this.tenant_id
  description = "Tenant ID of the managed identity."
}
