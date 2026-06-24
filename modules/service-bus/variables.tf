variable "name" {
  type        = string
  description = "Name of the Service Bus namespace (globally unique)."
}

variable "resource_group_name" {
  type        = string
  description = "Name of the resource group."
}

variable "location" {
  type        = string
  description = "Azure region."
}

variable "sku" {
  type        = string
  description = "Pricing tier of the namespace: Basic, Standard, or Premium."
  default     = "Standard"

  validation {
    condition     = contains(["Basic", "Standard", "Premium"], var.sku)
    error_message = "sku must be one of: Basic, Standard, Premium."
  }
}

variable "queues" {
  type = list(object({
    name                = string
    enable_partitioning = optional(bool, false)
  }))
  description = "List of queues to create inside the namespace. Topics require Standard or Premium SKU."
  default     = []
}

variable "topics" {
  type = list(object({
    name = string
  }))
  description = "List of topics to create inside the namespace. Topics require Standard or Premium SKU."
  default     = []
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply."
  default     = {}
}
