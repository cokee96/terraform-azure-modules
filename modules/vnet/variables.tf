variable "name" {
  type        = string
  description = "Name of the virtual network."
}

variable "resource_group_name" {
  type        = string
  description = "Name of the resource group."
}

variable "location" {
  type        = string
  description = "Azure region."
}

variable "address_space" {
  type        = list(string)
  description = "Address space for the VNet (e.g. [\"10.0.0.0/16\"])."
}

variable "subnets" {
  type = list(object({
    name             = string
    address_prefixes = list(string)

    # Associate an existing NSG. Pass module.nsg.id from the nsg module.
    nsg_id = optional(string)

    # Associate an existing route table.
    route_table_id = optional(string)

    # Azure service endpoints to enable on this subnet (e.g. ["Microsoft.Sql", "Microsoft.KeyVault"]).
    service_endpoints = optional(list(string), [])

    # Set to false for subnets that will host private endpoints. Required for PEPs to receive IPs.
    private_endpoint_network_policies_enabled = optional(bool, true)

    # Delegate the subnet to an Azure service (e.g. App Service VNet integration, Container Instances).
    delegation = optional(object({
      name = string
      service_delegation = object({
        name    = string
        actions = optional(list(string), [])
      })
    }))
  }))
  description = "List of subnets to create. Optional fields: nsg_id, route_table_id, service_endpoints, private_endpoint_network_policies_enabled, delegation."
  default     = []
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply."
  default     = {}
}
