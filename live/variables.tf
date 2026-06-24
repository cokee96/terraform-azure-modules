# ============================================================
# CORE — obligatorio en los tres entornos
# ============================================================

variable "project" {
  type        = string
  description = "Nombre corto del proyecto, sin espacios (ej. \"myapp\"). Se usa como prefijo en todos los recursos."
}

variable "environment" {
  type        = string
  description = "Entorno: dev | pre | prod."

  validation {
    condition     = contains(["dev", "pre", "prod"], var.environment)
    error_message = "environment debe ser dev, pre o prod."
  }
}

variable "location" {
  type        = string
  description = "Región de Azure donde se despliegan todos los recursos."
  default     = "westeurope"
}

variable "extra_tags" {
  type        = map(string)
  description = "Tags adicionales que se añaden a todos los recursos junto a project, environment y managed_by."
  default     = {}
}

# ============================================================
# RED
# ============================================================

variable "vnet_address_space" {
  type        = list(string)
  description = "Espacio de direcciones de la VNet (ej. [\"10.0.0.0/16\"])."
  default     = ["10.0.0.0/16"]
}

variable "subnet_aks_prefix" {
  type        = string
  description = "CIDR de la subnet para nodos de AKS."
  default     = "10.0.1.0/24"
}

variable "subnet_data_prefix" {
  type        = string
  description = "CIDR de la subnet para bases de datos y caché."
  default     = "10.0.2.0/24"
}

variable "subnet_endpoints_prefix" {
  type        = string
  description = "CIDR de la subnet dedicada a Private Endpoints."
  default     = "10.0.3.0/24"
}

# ============================================================
# AKS
# ============================================================

variable "aks_kubernetes_version" {
  type        = string
  description = "Versión de Kubernetes. Null usa la versión por defecto del API de Azure."
  default     = null
}

variable "aks_system_vm_size" {
  type        = string
  description = "Tamaño de VM para el node pool de sistema."
  default     = "Standard_D2s_v3"
}

variable "aks_system_node_count" {
  type        = number
  description = "Número de nodos inicial del pool de sistema."
  default     = 2
}

variable "aks_enable_auto_scaling" {
  type        = bool
  description = "Activa el autoscaler del cluster."
  default     = true
}

variable "aks_min_count" {
  type        = number
  description = "Mínimo de nodos (solo cuando aks_enable_auto_scaling = true)."
  default     = 2
}

variable "aks_max_count" {
  type        = number
  description = "Máximo de nodos (solo cuando aks_enable_auto_scaling = true)."
  default     = 5
}

# ============================================================
# ACR
# ============================================================

variable "acr_sku" {
  type        = string
  description = "SKU del Container Registry: Basic | Standard | Premium."
  default     = "Standard"
}

# ============================================================
# KEY VAULT
# ============================================================

variable "keyvault_sku_name" {
  type        = string
  description = "SKU del Key Vault: standard | premium."
  default     = "standard"
}

# ============================================================
# SQL DATABASE
# ============================================================

variable "sql_admin_password" {
  type        = string
  sensitive   = true
  description = "Contraseña del administrador del SQL Server. Pasar como variable de entorno: export TF_VAR_sql_admin_password=..."
}

variable "sql_sku_name" {
  type        = string
  description = "SKU de Azure SQL Database (ej. GP_S_Gen5_1, GP_Gen5_4)."
  default     = "GP_S_Gen5_1"
}

variable "sql_max_size_gb" {
  type        = number
  description = "Tamaño máximo de la base de datos en GB."
  default     = 32
}

# ============================================================
# REDIS CACHE
# ============================================================

variable "redis_sku_name" {
  type        = string
  description = "SKU de Azure Cache for Redis: Basic | Standard | Premium."
  default     = "Standard"
}

variable "redis_capacity" {
  type        = number
  description = "Capacidad de la caché. 0 en Basic/Standard = C0 (250 MB). Ver docs de Azure para valores válidos por SKU."
  default     = 1
}

variable "redis_family" {
  type        = string
  description = "Familia de caché: C (Basic/Standard) | P (Premium)."
  default     = "C"
}

# ============================================================
# APP SERVICE
# ============================================================

variable "app_sku_name" {
  type        = string
  description = "SKU del App Service Plan (ej. B1, B2, P1v3, P2v3)."
  default     = "B1"
}

variable "app_linux_fx_version" {
  type        = string
  description = "Runtime del web app en formato LANGUAGE|VERSION (ej. NODE|18-lts, PYTHON|3.11)."
  default     = "NODE|18-lts"
}

variable "app_extra_settings" {
  type        = map(string)
  description = "App settings adicionales que se inyectan como variables de entorno en el App Service."
  default     = {}
}

# ============================================================
# STORAGE
# ============================================================

variable "storage_replication_type" {
  type        = string
  description = "Tipo de replicación del Storage Account: LRS | GRS | RAGRS | ZRS."
  default     = "LRS"
}

# ============================================================
# SERVICE BUS
# ============================================================

variable "servicebus_sku" {
  type        = string
  description = "SKU del Service Bus: Basic | Standard | Premium."
  default     = "Standard"
}

variable "servicebus_queues" {
  type = list(object({
    name                 = string
    partitioning_enabled = optional(bool, false)
  }))
  description = "Colas a crear en el namespace de Service Bus."
  default     = []
}

variable "servicebus_topics" {
  type = list(object({
    name = string
  }))
  description = "Topics a crear en el namespace de Service Bus."
  default     = []
}

# ============================================================
# COSMOS DB
# ============================================================

variable "cosmosdb_consistency_level" {
  type        = string
  description = "Nivel de consistencia de Cosmos DB: Eventual | Session | BoundedStaleness | Strong | ConsistentPrefix."
  default     = "Session"
}

# ============================================================
# MONITORING
# ============================================================

variable "log_retention_days" {
  type        = number
  description = "Días de retención de logs en Log Analytics."
  default     = 30
}
