output "id" {
  value       = azurerm_virtual_network.this.id
  description = "Resource ID of the VNet."
}

output "name" {
  value       = azurerm_virtual_network.this.name
  description = "Name of the VNet."
}

output "subnet_ids" {
  value       = { for k, s in azurerm_subnet.this : k => s.id }
  description = "Map of subnet name to subnet ID."
}
