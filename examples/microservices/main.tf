module "resource_group" {
  source   = "../../modules/resource-group"
  name     = "rg-${local.prefix}"
  location = local.location
  tags     = local.tags
}

module "vnet" {
  source              = "../../modules/vnet"
  name                = "vnet-${local.prefix}"
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  address_space       = ["10.2.0.0/16"]
  subnets = [
    { name = "aks-nodes", address_prefixes = ["10.2.1.0/24"] },
    { name = "endpoints", address_prefixes = ["10.2.2.0/24"] },
  ]
  tags = local.tags
}

module "monitoring" {
  source              = "../../modules/monitoring"
  workspace_name      = "log-${local.prefix}"
  insights_name       = "appi-${local.prefix}"
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  retention_in_days   = 90
  application_type    = "web"
  tags                = local.tags
}

module "keyvault" {
  source              = "../../modules/keyvault"
  name                = "kv-msvcex-001"
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  tags                = local.tags
}

module "acr" {
  source              = "../../modules/acr"
  name                = "acrmsvcexample001"
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  sku                 = "Standard"
  tags                = local.tags
}

module "aks" {
  source              = "../../modules/aks"
  name                = "aks-${local.prefix}"
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  dns_prefix          = "msvcexample"
  subnet_id           = module.vnet.subnet_ids["aks-nodes"]
  system_node_count   = 2
  system_vm_size      = "Standard_D2s_v3"
  enable_auto_scaling = true
  min_count           = 2
  max_count           = 10
  enable_azure_rbac   = true
  tags                = local.tags
}

resource "azurerm_role_assignment" "aks_acr_pull" {
  scope                = module.acr.id
  role_definition_name = "AcrPull"
  principal_id         = module.aks.principal_id
}

module "service_bus" {
  source              = "../../modules/service-bus"
  name                = "sb-${local.prefix}"
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  sku                 = "Standard"
  queues = [
    { name = "orders", enable_partitioning = true },
    { name = "notifications" },
  ]
  topics = [
    { name = "events" },
    { name = "audit-log" },
  ]
  tags = local.tags
}

module "cosmosdb" {
  source              = "../../modules/cosmosdb"
  account_name        = "cosmos-msvcexample-001"
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  kind                = "GlobalDocumentDB"
  consistency_policy = {
    consistency_level       = "Session"
    max_interval_in_seconds = 5
    max_staleness_prefix    = 100
  }
  geo_locations = [
    { location = local.location, failover_priority = 0 }
  ]
  sql_database_name = "microservices"
  tags              = local.tags
}
