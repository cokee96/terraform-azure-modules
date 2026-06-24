output "server_id" {
  value       = azurerm_mssql_server.this.id
  description = "Resource ID of the SQL server."
}

output "server_fqdn" {
  value       = azurerm_mssql_server.this.fully_qualified_domain_name
  description = "Fully qualified domain name of the SQL server."
}

output "database_id" {
  value       = azurerm_mssql_database.this.id
  description = "Resource ID of the SQL database."
}

output "database_name" {
  value       = azurerm_mssql_database.this.name
  description = "Name of the SQL database."
}
