variable "account_name" {
  type        = string
  description = "Name of the Cosmos DB account (globally unique, lowercase alphanumeric and hyphens)."
}

variable "resource_group_name" {
  type        = string
  description = "Name of the resource group."
}

variable "location" {
  type        = string
  description = "Azure region."
}

variable "kind" {
  type        = string
  description = "Type of Cosmos DB account: GlobalDocumentDB (SQL), MongoDB, or Parse."
  default     = "GlobalDocumentDB"

  validation {
    condition     = contains(["GlobalDocumentDB", "MongoDB", "Parse"], var.kind)
    error_message = "kind must be one of: GlobalDocumentDB, MongoDB, Parse."
  }
}

variable "consistency_policy" {
  type = object({
    consistency_level       = string
    max_interval_in_seconds = number
    max_staleness_prefix    = number
  })
  description = "Consistency policy for the Cosmos DB account."
  default = {
    consistency_level       = "Session"
    max_interval_in_seconds = 5
    max_staleness_prefix    = 100
  }
}

variable "geo_locations" {
  type = list(object({
    location          = string
    failover_priority = number
  }))
  description = "List of geo-locations for the Cosmos DB account. At least one entry with failover_priority = 0 is required."
  default     = null
}

variable "sql_database_name" {
  type        = string
  description = "Name of the SQL database to create. Only applies when kind = GlobalDocumentDB."
  default     = "main"
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply."
  default     = {}
}
