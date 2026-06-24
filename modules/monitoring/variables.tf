variable "workspace_name" {
  type        = string
  description = "Name of the Log Analytics workspace."
}

variable "insights_name" {
  type        = string
  description = "Name of the Application Insights component."
}

variable "resource_group_name" {
  type        = string
  description = "Name of the resource group."
}

variable "location" {
  type        = string
  description = "Azure region."
}

variable "retention_in_days" {
  type        = number
  description = "Number of days to retain logs in the workspace (30–730)."
  default     = 30
}

variable "application_type" {
  type        = string
  description = "Type of Application Insights component (e.g. web, ios, other)."
  default     = "web"
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply."
  default     = {}
}
