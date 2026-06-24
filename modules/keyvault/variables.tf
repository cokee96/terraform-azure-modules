variable "name" {
  type        = string
  description = "Name of the Key Vault (3-24 chars, globally unique)."
}

variable "location" {
  type        = string
  description = "Azure region."
}

variable "resource_group_name" {
  type        = string
  description = "Name of the resource group."
}

variable "sku_name" {
  type        = string
  description = "SKU: standard or premium."
  default     = "standard"

  validation {
    condition     = contains(["standard", "premium"], var.sku_name)
    error_message = "sku_name must be standard or premium."
  }
}

variable "soft_delete_retention_days" {
  type        = number
  description = "Days to retain soft-deleted items (7–90)."
  default     = 90
}

variable "purge_protection_enabled" {
  type        = bool
  description = "Enable purge protection. Cannot be disabled once enabled."
  default     = true
}

variable "enable_rbac_authorization" {
  type        = bool
  description = "Use RBAC instead of access policies for authorization."
  default     = true
}

variable "network_acls" {
  type = object({
    default_action             = string
    bypass                     = list(string)
    ip_rules                   = optional(list(string), [])
    virtual_network_subnet_ids = optional(list(string), [])
  })
  description = "Network ACL configuration. Set default_action to Deny for production."
  default     = null
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply."
  default     = {}
}
