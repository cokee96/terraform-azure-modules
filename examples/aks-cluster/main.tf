module "resource_group" {
  source   = "../../modules/resource-group"
  name     = "rg-aks-example"
  location = "westeurope"
  tags     = local.tags
}

module "vnet" {
  source              = "../../modules/vnet"
  name                = "vnet-aks-example"
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  address_space       = ["10.0.0.0/16"]
  subnets = [
    {
      name              = "aks-nodes"
      address_prefixes  = ["10.0.1.0/24"]
      service_endpoints = ["Microsoft.ContainerRegistry"]
    },
    {
      name                                      = "endpoints"
      address_prefixes                          = ["10.0.2.0/24"]
      private_endpoint_network_policies_enabled = false
    },
  ]
  tags = local.tags
}

module "acr" {
  source              = "../../modules/acr"
  name                = "acraksexample"
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  sku                 = "Standard"
  tags                = local.tags
}

module "aks" {
  source              = "../../modules/aks"
  name                = "aks-example"
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  dns_prefix          = "aks-example"
  subnet_id           = module.vnet.subnet_ids["aks-nodes"]
  system_node_count   = 2
  system_vm_size      = "Standard_D2s_v3"
  enable_auto_scaling = true
  min_count           = 2
  max_count           = 5
  enable_azure_rbac   = true
  tags                = local.tags
}

resource "azurerm_role_assignment" "aks_acr_pull" {
  scope                = module.acr.id
  role_definition_name = "AcrPull"
  principal_id         = module.aks.principal_id
}
