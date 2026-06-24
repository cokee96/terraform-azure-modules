variable "namespace_name" {
  type        = string
  description = "Name of the Event Hub namespace (globally unique)."
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

variable "capacity" {
  type        = number
  description = "Throughput units for the namespace (1–40 for Standard, 1–1 for Premium CUs)."
  default     = 1
}

variable "event_hubs" {
  type = list(object({
    name              = string
    partition_count   = optional(number, 2)
    message_retention = optional(number, 1)
  }))
  description = "List of Event Hubs to create inside the namespace."
  default     = []
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply."
  default     = {}
}
