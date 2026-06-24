variable "name" {
  type        = string
  description = "Name of the Function App. The service plan is created as \"<name>-plan\"."
}

variable "resource_group_name" {
  type        = string
  description = "Name of the resource group."
}

variable "location" {
  type        = string
  description = "Azure region."
}

variable "sku_name" {
  type        = string
  description = "SKU name for the hosting plan. Use Y1 for Consumption (serverless), EP1/EP2/EP3 for Elastic Premium."
  default     = "Y1"
}

variable "storage_account_name" {
  type        = string
  description = "Name of the storage account created for the Function App. Defaults to \"<name_without_hyphens>sa\" if null."
  default     = null
}

variable "runtime" {
  type = object({
    name    = string
    version = string
  })
  description = "Runtime stack for the Function App. name can be python, node, java, or dotnet."
  default = {
    name    = "python"
    version = "3.11"
  }
}

variable "app_settings" {
  type        = map(string)
  description = "Application settings (environment variables) for the Function App."
  default     = {}
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply."
  default     = {}
}
