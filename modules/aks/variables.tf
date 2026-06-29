variable "name" {
  type        = string
  description = "Name of the AKS cluster."
}

variable "location" {
  type        = string
  description = "Azure region."
}

variable "resource_group_name" {
  type        = string
  description = "Name of the resource group."
}

variable "dns_prefix" {
  type        = string
  description = "DNS prefix for the cluster."
}

variable "kubernetes_version" {
  type        = string
  description = "Kubernetes version."
  default     = null
}

variable "subnet_id" {
  type        = string
  description = "Subnet ID for the node pool."
  default     = null
}

variable "system_node_count" {
  type        = number
  description = "Initial node count for the system node pool."
  default     = 2
}

variable "system_vm_size" {
  type        = string
  description = "VM size for the system node pool."
  default     = "Standard_D2s_v3"
}

variable "enable_auto_scaling" {
  type        = bool
  description = "Enable cluster autoscaler."
  default     = false
}

variable "min_count" {
  type        = number
  description = "Minimum node count (autoscaler)."
  default     = 1
}

variable "max_count" {
  type        = number
  description = "Maximum node count (autoscaler)."
  default     = 5
}

variable "enable_azure_rbac" {
  type        = bool
  description = "Enable Azure RBAC for Kubernetes authorization."
  default     = false
}

variable "admin_group_object_ids" {
  type        = list(string)
  description = "Object IDs of AAD groups with cluster admin role (required when enable_azure_rbac=true)."
  default     = []
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply."
  default     = {}
}
