# ============================================================
# RESOURCE GROUP
# ============================================================

module "resource_group" {
  source   = "../modules/resource-group"
  name     = local.names.resource_group
  location = var.location
  tags     = local.tags
}

# ============================================================
# RED — NSG + VNet + Subnets
# ============================================================

module "nsg_aks" {
  source              = "../modules/nsg"
  name                = local.names.nsg_aks
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  rules = [
    {
      name                       = "allow-https-inbound"
      priority                   = 100
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "443"
      source_address_prefix      = "Internet"
      destination_address_prefix = "*"
    },
    {
      name                       = "allow-http-inbound"
      priority                   = 110
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "80"
      source_address_prefix      = "Internet"
      destination_address_prefix = "*"
    },
  ]
  tags = local.tags
}

module "vnet" {
  source              = "../modules/vnet"
  name                = local.names.vnet
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  address_space       = var.vnet_address_space
  subnets = [
    {
      name              = "aks-nodes"
      address_prefixes  = [var.subnet_aks_prefix]
      nsg_id            = module.nsg_aks.id
      service_endpoints = ["Microsoft.ContainerRegistry", "Microsoft.KeyVault"]
    },
    {
      name              = "data"
      address_prefixes  = [var.subnet_data_prefix]
      service_endpoints = ["Microsoft.Sql", "Microsoft.Storage"]
    },
    {
      # Los Private Endpoints necesitan esta política desactivada
      name                                      = "endpoints"
      address_prefixes                          = [var.subnet_endpoints_prefix]
      private_endpoint_network_policies_enabled = false
    },
  ]
  tags = local.tags
}

# ============================================================
# OBSERVABILIDAD
# ============================================================

module "monitoring" {
  source              = "../modules/monitoring"
  workspace_name      = local.names.log_workspace
  insights_name       = local.names.app_insights
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  retention_in_days   = var.log_retention_days
  application_type    = "web"
  tags                = local.tags
}

# ============================================================
# SEGURIDAD
# ============================================================

module "keyvault" {
  source              = "../modules/keyvault"
  name                = local.names.keyvault
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  sku_name            = var.keyvault_sku_name
  tags                = local.tags
}

module "pe_keyvault" {
  source                         = "../modules/private-endpoint"
  name                           = local.names.pe_keyvault
  resource_group_name            = module.resource_group.name
  location                       = module.resource_group.location
  subnet_id                      = module.vnet.subnet_ids["endpoints"]
  private_connection_resource_id = module.keyvault.id
  subresource_names              = ["vault"]
  tags                           = local.tags
}

# ============================================================
# CONTENEDORES — ACR + AKS
# ============================================================

module "acr" {
  source              = "../modules/acr"
  name                = local.names.acr
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  sku                 = var.acr_sku
  tags                = local.tags
}

module "pe_acr" {
  source                         = "../modules/private-endpoint"
  name                           = local.names.pe_acr
  resource_group_name            = module.resource_group.name
  location                       = module.resource_group.location
  subnet_id                      = module.vnet.subnet_ids["endpoints"]
  private_connection_resource_id = module.acr.id
  subresource_names              = ["registry"]
  tags                           = local.tags
}

module "aks" {
  source              = "../modules/aks"
  name                = local.names.aks
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  dns_prefix          = "${var.project}-${var.environment}"
  kubernetes_version  = var.aks_kubernetes_version
  subnet_id           = module.vnet.subnet_ids["aks-nodes"]
  system_vm_size      = var.aks_system_vm_size
  system_node_count   = var.aks_system_node_count
  enable_auto_scaling = var.aks_enable_auto_scaling
  min_count           = var.aks_min_count
  max_count           = var.aks_max_count
  enable_azure_rbac   = true
  tags                = local.tags
}

resource "azurerm_role_assignment" "aks_acr_pull" {
  scope                = module.acr.id
  role_definition_name = "AcrPull"
  principal_id         = module.aks.principal_id
}

resource "azurerm_role_assignment" "aks_keyvault" {
  scope                = module.keyvault.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = module.aks.principal_id
}

# ============================================================
# ALMACENAMIENTO
# ============================================================

module "storage" {
  source                          = "../modules/storage-account"
  name                            = local.names.storage
  resource_group_name             = module.resource_group.name
  location                        = module.resource_group.location
  account_replication_type        = var.storage_replication_type
  allow_nested_items_to_be_public = false
  containers = [
    { name = "assets", access_type = "private" },
    { name = "uploads", access_type = "private" },
  ]
  tags = local.tags
}

module "pe_storage" {
  source                         = "../modules/private-endpoint"
  name                           = local.names.pe_storage
  resource_group_name            = module.resource_group.name
  location                       = module.resource_group.location
  subnet_id                      = module.vnet.subnet_ids["endpoints"]
  private_connection_resource_id = module.storage.id
  subresource_names              = ["blob"]
  tags                           = local.tags
}

# ============================================================
# BASE DE DATOS — SQL
# ============================================================

module "sql" {
  source              = "../modules/sql-database"
  server_name         = local.names.sql_server
  db_name             = local.names.sql_database
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  admin_login         = "sqladmin"
  admin_password      = var.sql_admin_password
  db_sku_name         = var.sql_sku_name
  max_size_gb         = var.sql_max_size_gb
  tags                = local.tags
}

module "pe_sql" {
  source                         = "../modules/private-endpoint"
  name                           = local.names.pe_sql
  resource_group_name            = module.resource_group.name
  location                       = module.resource_group.location
  subnet_id                      = module.vnet.subnet_ids["endpoints"]
  private_connection_resource_id = module.sql.server_id
  subresource_names              = ["sqlServer"]
  tags                           = local.tags
}

# ============================================================
# CACHÉ — Redis
# ============================================================

module "redis" {
  source              = "../modules/redis-cache"
  name                = local.names.redis
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  sku_name            = var.redis_sku_name
  capacity            = var.redis_capacity
  family              = var.redis_family
  tags                = local.tags
}

module "pe_redis" {
  source                         = "../modules/private-endpoint"
  name                           = local.names.pe_redis
  resource_group_name            = module.resource_group.name
  location                       = module.resource_group.location
  subnet_id                      = module.vnet.subnet_ids["endpoints"]
  private_connection_resource_id = module.redis.id
  subresource_names              = ["redisCache"]
  tags                           = local.tags
}

# ============================================================
# APP SERVICE
# ============================================================

module "app_service" {
  source              = "../modules/app-service"
  name                = local.names.app_service
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  sku_name            = var.app_sku_name
  linux_fx_version    = var.app_linux_fx_version
  app_settings = merge(
    {
      APPINSIGHTS_INSTRUMENTATIONKEY        = module.monitoring.instrumentation_key
      APPLICATIONINSIGHTS_CONNECTION_STRING = module.monitoring.connection_string
      REDIS_HOST                            = module.redis.hostname
      REDIS_PORT                            = tostring(module.redis.ssl_port)
      SQL_SERVER_FQDN                       = module.sql.server_fqdn
      SQL_DATABASE_NAME                     = module.sql.database_name
      STORAGE_ACCOUNT_NAME                  = module.storage.name
      STORAGE_BLOB_ENDPOINT                 = module.storage.primary_blob_endpoint
      KEYVAULT_URI                          = module.keyvault.vault_uri
      SERVICEBUS_CONNECTION_STRING          = module.servicebus.primary_connection_string
    },
    var.app_extra_settings
  )
  tags = local.tags
}

# ============================================================
# MENSAJERÍA — Service Bus
# ============================================================

module "servicebus" {
  source              = "../modules/service-bus"
  name                = local.names.servicebus
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  sku                 = var.servicebus_sku
  queues              = var.servicebus_queues
  topics              = var.servicebus_topics
  tags                = local.tags
}

module "pe_servicebus" {
  source                         = "../modules/private-endpoint"
  name                           = local.names.pe_servicebus
  resource_group_name            = module.resource_group.name
  location                       = module.resource_group.location
  subnet_id                      = module.vnet.subnet_ids["endpoints"]
  private_connection_resource_id = module.servicebus.id
  subresource_names              = ["namespace"]
  tags                           = local.tags
}

# ============================================================
# BASE DE DATOS — Cosmos DB
# ============================================================

module "cosmosdb" {
  source              = "../modules/cosmosdb"
  account_name        = local.names.cosmosdb
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  kind                = "GlobalDocumentDB"
  consistency_policy = {
    consistency_level       = var.cosmosdb_consistency_level
    max_interval_in_seconds = 5
    max_staleness_prefix    = 100
  }
  geo_locations = [
    { location = var.location, failover_priority = 0 }
  ]
  sql_database_name = "main"
  tags              = local.tags
}

module "pe_cosmosdb" {
  source                         = "../modules/private-endpoint"
  name                           = local.names.pe_cosmosdb
  resource_group_name            = module.resource_group.name
  location                       = module.resource_group.location
  subnet_id                      = module.vnet.subnet_ids["endpoints"]
  private_connection_resource_id = module.cosmosdb.id
  subresource_names              = ["Sql"]
  tags                           = local.tags
}
