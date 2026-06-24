output "workspace_id" {
  value       = azurerm_log_analytics_workspace.this.id
  description = "Resource ID of the Log Analytics workspace."
}

output "workspace_name" {
  value       = azurerm_log_analytics_workspace.this.name
  description = "Name of the Log Analytics workspace."
}

output "insights_id" {
  value       = azurerm_application_insights.this.id
  description = "Resource ID of the Application Insights component."
}

output "insights_name" {
  value       = azurerm_application_insights.this.name
  description = "Name of the Application Insights component."
}

output "instrumentation_key" {
  value       = azurerm_application_insights.this.instrumentation_key
  sensitive   = true
  description = "Instrumentation key for the Application Insights component."
}

output "connection_string" {
  value       = azurerm_application_insights.this.connection_string
  sensitive   = true
  description = "Connection string for the Application Insights component."
}
