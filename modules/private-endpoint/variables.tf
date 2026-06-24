variable "name" {
  type        = string
  description = "Name of the private endpoint."
}

variable "resource_group_name" {
  type        = string
  description = "Name of the resource group."
}

variable "location" {
  type        = string
  description = "Azure region."
}

variable "subnet_id" {
  type        = string
  description = "ID of the subnet in which to place the private endpoint."
}

variable "private_connection_resource_id" {
  type        = string
  description = "Resource ID of the service to connect to via the private endpoint."
}

variable "subresource_names" {
  type        = list(string)
  description = "List of sub-resource names for the private service connection (e.g. [\"blob\"], [\"sqlServer\"])."
}

variable "private_dns_zone_ids" {
  type        = list(string)
  description = "List of private DNS zone IDs to associate with the endpoint. Leave empty to skip DNS zone group creation."
  default     = []
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply."
  default     = {}
}
