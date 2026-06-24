variable "server_name" {
  type        = string
  description = "Name of the SQL server (globally unique)."
}

variable "db_name" {
  type        = string
  description = "Name of the SQL database."
}

variable "resource_group_name" {
  type        = string
  description = "Name of the resource group."
}

variable "location" {
  type        = string
  description = "Azure region."
}

variable "admin_login" {
  type        = string
  description = "Administrator login name for the SQL server."
  default     = "sqladmin"
}

variable "admin_password" {
  type        = string
  sensitive   = true
  description = "Administrator login password for the SQL server."
}

variable "db_sku_name" {
  type        = string
  description = "SKU name for the database (e.g. GP_S_Gen5_1, S0, Basic)."
  default     = "GP_S_Gen5_1"
}

variable "max_size_gb" {
  type        = number
  description = "Maximum size of the database in gigabytes."
  default     = 32
}

variable "aad_admin" {
  type = object({
    login_username = string
    object_id      = string
    tenant_id      = string
  })
  description = "Azure Active Directory administrator for the SQL server. Set to null to disable."
  default     = null
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply."
  default     = {}
}
