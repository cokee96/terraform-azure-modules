module "resource_group" {
  source   = "../../modules/resource-group"
  name     = "rg-${local.prefix}"
  location = local.location
  tags     = local.tags
}

# NSG for the application subnet — allow HTTPS inbound, deny everything else
module "nsg_app" {
  source              = "../../modules/nsg"
  name                = "nsg-app-${local.prefix}"
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
  source              = "../../modules/vnet"
  name                = "vnet-${local.prefix}"
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  address_space       = ["10.1.0.0/16"]
  subnets = [
    {
      name             = "app"
      address_prefixes = ["10.1.1.0/24"]
      nsg_id           = module.nsg_app.id
      # Service endpoints allow KeyVault and SQL to restrict access to this subnet
      service_endpoints = ["Microsoft.KeyVault", "Microsoft.Sql", "Microsoft.Storage"]
    },
    {
      name             = "data"
      address_prefixes = ["10.1.2.0/24"]
      service_endpoints = ["Microsoft.Sql", "Microsoft.Storage"]
    },
    {
      # Private endpoints require this to be false so the subnet can assign IPs to PEPs
      name                                      = "endpoints"
      address_prefixes                          = ["10.1.3.0/24"]
      private_endpoint_network_policies_enabled = false
    },
  ]
  tags = local.tags
}

module "monitoring" {
  source              = "../../modules/monitoring"
  workspace_name      = "log-${local.prefix}"
  insights_name       = "appi-${local.prefix}"
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  retention_in_days   = 30
  application_type    = "web"
  tags                = local.tags
}

module "keyvault" {
  source              = "../../modules/keyvault"
  name                = "kv-webappex-001"
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  tags                = local.tags
}

module "storage" {
  source                          = "../../modules/storage-account"
  name                            = "stwebappexample001"
  resource_group_name             = module.resource_group.name
  location                        = module.resource_group.location
  account_tier                    = "Standard"
  account_replication_type        = "LRS"
  allow_nested_items_to_be_public = false
  containers = [
    { name = "assets",  access_type = "private" },
    { name = "uploads", access_type = "private" },
  ]
  tags = local.tags
}

module "sql" {
  source              = "../../modules/sql-database"
  server_name         = "sql-${local.prefix}"
  db_name             = "appdb"
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  admin_login         = "sqladmin"
  admin_password      = var.sql_admin_password
  db_sku_name         = "GP_S_Gen5_1"
  max_size_gb         = 32
  tags                = local.tags
}

module "redis" {
  source              = "../../modules/redis-cache"
  name                = "redis-${local.prefix}"
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  capacity            = 1
  family              = "C"
  sku_name            = "Standard"
  tags                = local.tags
}

module "app_service" {
  source              = "../../modules/app-service"
  name                = "app-${local.prefix}"
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  sku_name            = "B2"
  linux_fx_version    = "NODE|18-lts"
  app_settings = {
    APPINSIGHTS_INSTRUMENTATIONKEY        = module.monitoring.instrumentation_key
    APPLICATIONINSIGHTS_CONNECTION_STRING = module.monitoring.connection_string
    REDIS_HOST                            = module.redis.hostname
    REDIS_PORT                            = tostring(module.redis.ssl_port)
    SQL_SERVER_FQDN                       = module.sql.server_fqdn
    SQL_DATABASE_NAME                     = module.sql.database_name
    STORAGE_ACCOUNT_NAME                  = module.storage.name
    STORAGE_BLOB_ENDPOINT                 = module.storage.primary_blob_endpoint
    KEYVAULT_URI                          = module.keyvault.vault_uri
  }
  tags = local.tags
}

# Private endpoints — all pointing at the dedicated endpoints subnet
module "pe_sql" {
  source                         = "../../modules/private-endpoint"
  name                           = "pe-sql-${local.prefix}"
  resource_group_name            = module.resource_group.name
  location                       = module.resource_group.location
  subnet_id                      = module.vnet.subnet_ids["endpoints"]
  private_connection_resource_id = module.sql.server_id
  subresource_names              = ["sqlServer"]
  tags                           = local.tags
}

module "pe_keyvault" {
  source                         = "../../modules/private-endpoint"
  name                           = "pe-kv-${local.prefix}"
  resource_group_name            = module.resource_group.name
  location                       = module.resource_group.location
  subnet_id                      = module.vnet.subnet_ids["endpoints"]
  private_connection_resource_id = module.keyvault.id
  subresource_names              = ["vault"]
  tags                           = local.tags
}

module "pe_storage_blob" {
  source                         = "../../modules/private-endpoint"
  name                           = "pe-st-blob-${local.prefix}"
  resource_group_name            = module.resource_group.name
  location                       = module.resource_group.location
  subnet_id                      = module.vnet.subnet_ids["endpoints"]
  private_connection_resource_id = module.storage.id
  subresource_names              = ["blob"]
  tags                           = local.tags
}

variable "sql_admin_password" {
  type        = string
  sensitive   = true
  description = "Administrator password for the SQL server."
}
