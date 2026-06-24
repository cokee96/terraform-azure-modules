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
  }))
  description = "List of subnets to create inside the VNet."
  default     = []
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply."
  default     = {}
}
