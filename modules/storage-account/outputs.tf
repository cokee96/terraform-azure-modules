output "id" {
  value       = azurerm_storage_account.this.id
  description = "Resource ID of the storage account."
}

output "name" {
  value       = azurerm_storage_account.this.name
  description = "Name of the storage account."
}

output "primary_blob_endpoint" {
  value       = azurerm_storage_account.this.primary_blob_endpoint
  description = "Primary blob service endpoint URL."
}

output "primary_connection_string" {
  value       = azurerm_storage_account.this.primary_connection_string
  sensitive   = true
  description = "Primary connection string for the storage account."
}
