output "id" {
  value       = azurerm_cosmosdb_account.this.id
  description = "Resource ID of the Cosmos DB account."
}

output "name" {
  value       = azurerm_cosmosdb_account.this.name
  description = "Name of the Cosmos DB account."
}

output "endpoint" {
  value       = azurerm_cosmosdb_account.this.endpoint
  description = "Endpoint URL of the Cosmos DB account."
}

output "primary_key" {
  value       = azurerm_cosmosdb_account.this.primary_key
  sensitive   = true
  description = "Primary master key for the Cosmos DB account."
}

output "primary_connection_string" {
  value       = azurerm_cosmosdb_account.this.primary_sql_connection_string
  sensitive   = true
  description = "Primary SQL connection string for the Cosmos DB account."
}

output "sql_database_id" {
  value       = length(azurerm_cosmosdb_sql_database.this) > 0 ? azurerm_cosmosdb_sql_database.this[0].id : null
  description = "Resource ID of the SQL database. Null when kind is not GlobalDocumentDB."
}
