variable "name" {
  type        = string
  description = "Name of the Linux Web App. The service plan is created as \"<name>-plan\"."
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
  description = "SKU name for the App Service Plan (e.g. B1, B2, S1, P1v3)."
  default     = "B1"
}

variable "linux_fx_version" {
  type        = string
  description = "Runtime stack in the form LANGUAGE|VERSION (e.g. NODE|18-lts, PYTHON|3.11, DOTNETCORE|8.0, PHP|8.2)."
  default     = "NODE|18-lts"
}

variable "app_settings" {
  type        = map(string)
  description = "Application settings (environment variables) for the Web App."
  default     = {}
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply."
  default     = {}
}
