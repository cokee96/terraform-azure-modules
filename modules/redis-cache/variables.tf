variable "name" {
  type        = string
  description = "Name of the Redis Cache instance (globally unique)."
}

variable "resource_group_name" {
  type        = string
  description = "Name of the resource group."
}

variable "location" {
  type        = string
  description = "Azure region."
}

variable "capacity" {
  type        = number
  description = "Cache capacity. For C family: 0-6. For P family: 1-5."
  default     = 1
}

variable "family" {
  type        = string
  description = "Cache family: C (Basic/Standard) or P (Premium)."
  default     = "C"

  validation {
    condition     = contains(["C", "P"], var.family)
    error_message = "family must be C or P."
  }
}

variable "sku_name" {
  type        = string
  description = "Cache SKU: Basic, Standard, or Premium."
  default     = "Standard"

  validation {
    condition     = contains(["Basic", "Standard", "Premium"], var.sku_name)
    error_message = "sku_name must be one of: Basic, Standard, Premium."
  }
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply."
  default     = {}
}
