output "id" {
  value       = azurerm_redis_cache.this.id
  description = "Resource ID of the Redis Cache."
}

output "hostname" {
  value       = azurerm_redis_cache.this.hostname
  description = "Hostname of the Redis Cache endpoint."
}

output "ssl_port" {
  value       = azurerm_redis_cache.this.ssl_port
  description = "SSL port of the Redis Cache endpoint."
}

output "primary_access_key" {
  value       = azurerm_redis_cache.this.primary_access_key
  sensitive   = true
  description = "Primary access key for the Redis Cache."
}

output "primary_connection_string" {
  value       = azurerm_redis_cache.this.primary_connection_string
  sensitive   = true
  description = "Primary connection string for the Redis Cache."
}
