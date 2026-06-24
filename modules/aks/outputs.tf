output "id" {
  value       = azurerm_kubernetes_cluster.this.id
  description = "Resource ID of the AKS cluster."
}

output "name" {
  value       = azurerm_kubernetes_cluster.this.name
  description = "Name of the AKS cluster."
}

output "kube_config_raw" {
  value       = azurerm_kubernetes_cluster.this.kube_config_raw
  sensitive   = true
  description = "Raw kubeconfig for the cluster."
}

output "principal_id" {
  value       = azurerm_kubernetes_cluster.this.identity[0].principal_id
  description = "Principal ID of the cluster's managed identity."
}
