output "resource_group_name" {
  value       = module.resource_group.name
  description = "Nombre del Resource Group."
}

output "aks_name" {
  value       = module.aks.name
  description = "Nombre del cluster AKS."
}

output "aks_get_credentials" {
  value       = "az aks get-credentials --resource-group ${module.resource_group.name} --name ${module.aks.name}"
  description = "Comando para obtener las credenciales de kubectl."
}

output "acr_login_server" {
  value       = module.acr.login_server
  description = "URL del registro de contenedores (ej. myacr.azurecr.io)."
}

output "keyvault_uri" {
  value       = module.keyvault.vault_uri
  description = "URI del Key Vault."
}

output "sql_server_fqdn" {
  value       = module.sql.server_fqdn
  description = "FQDN del SQL Server."
}

output "redis_hostname" {
  value       = module.redis.hostname
  description = "Hostname de Redis."
}

output "app_service_url" {
  value       = "https://${module.app_service.default_hostname}"
  description = "URL del App Service."
}

output "servicebus_endpoint" {
  value       = module.servicebus.endpoint
  description = "Endpoint del Service Bus namespace."
}

output "cosmosdb_endpoint" {
  value       = module.cosmosdb.endpoint
  description = "Endpoint del Cosmos DB."
}

output "storage_blob_endpoint" {
  value       = module.storage.primary_blob_endpoint
  description = "Endpoint blob del Storage Account."
}

output "monitoring_workspace_id" {
  value       = module.monitoring.workspace_id
  description = "ID del workspace de Log Analytics."
}

output "app_insights_connection_string" {
  value       = module.monitoring.connection_string
  sensitive   = true
  description = "Connection string de Application Insights."
}
