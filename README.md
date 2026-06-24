# terraform-azure-modules

> A curated library of opinionated, reusable Terraform modules for Microsoft Azure.

![Terraform](https://img.shields.io/badge/terraform-%3E%3D1.3.0-purple)
![AzureRM](https://img.shields.io/badge/azurerm-%3E%3D3.0.0-blue)
![License](https://img.shields.io/badge/license-MIT-green)

---

## Overview

This repository contains a collection of production-ready Terraform modules for provisioning common Azure infrastructure components. Each module is designed to be self-contained, composable, and safe by default, so teams can build from individual building blocks without re-implementing standard patterns from scratch.

### Design principles

- **Consistent interface** — Every module follows the same file layout (`main.tf`, `variables.tf`, `outputs.tf`, `versions.tf`), uses `this` as the primary resource name, and exposes a standard `tags` variable.
- **Safe defaults** — Insecure defaults are avoided wherever possible. TLS 1.2 is enforced on database and cache resources. Public blob access is disabled on storage accounts. Key Vault purge protection defaults to enabled.
- **Composable** — Modules expose all IDs and connection details as outputs so they can be chained together without hard-coding values. See the [Connecting modules](#connecting-modules) section for examples.
- **Minimal footprint** — Each module manages a single logical component and its directly dependent sub-resources (e.g. subnets inside a VNet, containers inside a storage account). Cross-resource wiring (role assignments, DNS zones) is left to the calling configuration to keep modules decoupled.

---

## Module catalog

| Module | Description | Key resources |
|---|---|---|
| [resource-group](#modulesresource-group) | Azure Resource Group | `azurerm_resource_group` |
| [vnet](#modulesvnet) | Virtual Network with subnets | `azurerm_virtual_network`, `azurerm_subnet` |
| [aks](#modulesaks) | Azure Kubernetes Service cluster | `azurerm_kubernetes_cluster` |
| [acr](#modulesacr) | Azure Container Registry | `azurerm_container_registry` |
| [keyvault](#moduleskeyvault) | Azure Key Vault | `azurerm_key_vault` |
| [storage-account](#modulesstorage-account) | Storage Account with containers | `azurerm_storage_account`, `azurerm_storage_container` |
| [app-service](#modulesapp-service) | Linux App Service Plan + Web App | `azurerm_service_plan`, `azurerm_linux_web_app` |
| [sql-database](#modulessql-database) | Azure SQL Server + Database | `azurerm_mssql_server`, `azurerm_mssql_database` |
| [redis-cache](#modulesredis-cache) | Azure Cache for Redis | `azurerm_redis_cache` |
| [monitoring](#modulesmonitoring) | Log Analytics + Application Insights | `azurerm_log_analytics_workspace`, `azurerm_application_insights` |
| [private-endpoint](#modulesprivate-endpoint) | Private Endpoint with optional DNS zone group | `azurerm_private_endpoint` |
| [nsg](#modulesnsg) | Network Security Group with rules | `azurerm_network_security_group`, `azurerm_network_security_rule` |
| [managed-identity](#modulesmanaged-identity) | User-assigned Managed Identity | `azurerm_user_assigned_identity` |
| [service-bus](#modulesservice-bus) | Service Bus namespace, queues, and topics | `azurerm_servicebus_namespace`, `azurerm_servicebus_queue`, `azurerm_servicebus_topic` |
| [cosmosdb](#modulescosmosdb) | Cosmos DB account and SQL database | `azurerm_cosmosdb_account`, `azurerm_cosmosdb_sql_database` |
| [function-app](#modulesfunction-app) | Linux Function App with backing storage | `azurerm_linux_function_app`, `azurerm_service_plan`, `azurerm_storage_account` |
| [event-hub](#modulesevent-hub) | Event Hub namespace and hubs | `azurerm_eventhub_namespace`, `azurerm_eventhub` |

---

## Requirements

| Requirement | Version |
|---|---|
| [Terraform](https://developer.hashicorp.com/terraform/downloads) | `>= 1.3.0` |
| [AzureRM provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest) | `>= 3.0.0` |
| [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli) | Any recent version |

Authenticate before running any `terraform` commands:

```bash
az login
az account set --subscription "<your-subscription-id>"
```

---

## Quick start

```hcl
# versions.tf
terraform {
  required_version = ">= 1.3.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.0.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# main.tf
module "resource_group" {
  source   = "github.com/your-org/terraform-azure-modules//modules/resource-group"
  name     = "rg-my-app"
  location = "westeurope"
  tags = {
    environment = "production"
    managed_by  = "terraform"
  }
}

module "vnet" {
  source              = "github.com/your-org/terraform-azure-modules//modules/vnet"
  name                = "vnet-my-app"
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  address_space       = ["10.0.0.0/16"]
  subnets = [
    { name = "app", address_prefixes = ["10.0.1.0/24"] },
  ]
  tags = module.resource_group.tags
}
```

Then run:

```bash
terraform init
terraform plan
terraform apply
```

---

## Module reference

### modules/resource-group

Creates an Azure Resource Group.

#### Usage

```hcl
module "resource_group" {
  source   = "../../modules/resource-group"
  name     = "rg-my-app-prod"
  location = "westeurope"
  tags = {
    environment = "production"
    managed_by  = "terraform"
  }
}
```

#### Inputs

| Name | Type | Default | Description |
|---|---|---|---|
| `name` | `string` | — | Name of the resource group. |
| `location` | `string` | — | Azure region. |
| `tags` | `map(string)` | `{}` | Tags to apply. |

#### Outputs

| Name | Description |
|---|---|
| `id` | Resource ID of the resource group. |
| `name` | Name of the resource group. |
| `location` | Location of the resource group. |

---

### modules/vnet

Creates an Azure Virtual Network with one or more subnets.

#### Usage

```hcl
module "vnet" {
  source              = "../../modules/vnet"
  name                = "vnet-my-app"
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  address_space       = ["10.0.0.0/16"]
  subnets = [
    { name = "aks-nodes",  address_prefixes = ["10.0.1.0/24"] },
    { name = "endpoints",  address_prefixes = ["10.0.2.0/24"] },
  ]
  tags = local.tags
}
```

#### Inputs

| Name | Type | Default | Description |
|---|---|---|---|
| `name` | `string` | — | Name of the virtual network. |
| `resource_group_name` | `string` | — | Name of the resource group. |
| `location` | `string` | — | Azure region. |
| `address_space` | `list(string)` | — | Address space (e.g. `["10.0.0.0/16"]`). |
| `subnets` | `list(object)` | `[]` | List of subnets with `name` and `address_prefixes`. |
| `tags` | `map(string)` | `{}` | Tags to apply. |

#### Outputs

| Name | Description |
|---|---|
| `id` | Resource ID of the VNet. |
| `name` | Name of the VNet. |
| `subnet_ids` | Map of subnet name to subnet ID. |

---

### modules/aks

Creates an Azure Kubernetes Service cluster with a system node pool and SystemAssigned identity.

#### Usage

```hcl
module "aks" {
  source              = "../../modules/aks"
  name                = "aks-my-app"
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  dns_prefix          = "my-app"
  subnet_id           = module.vnet.subnet_ids["aks-nodes"]
  system_node_count   = 2
  system_vm_size      = "Standard_D2s_v3"
  enable_auto_scaling = true
  min_count           = 2
  max_count           = 10
  enable_azure_rbac   = true
  tags                = local.tags
}
```

#### Inputs

| Name | Type | Default | Description |
|---|---|---|---|
| `name` | `string` | — | Name of the AKS cluster. |
| `resource_group_name` | `string` | — | Name of the resource group. |
| `location` | `string` | — | Azure region. |
| `dns_prefix` | `string` | — | DNS prefix for the cluster. |
| `kubernetes_version` | `string` | `null` | Kubernetes version. |
| `subnet_id` | `string` | `null` | Subnet ID for the node pool. |
| `system_node_count` | `number` | `2` | Initial node count. |
| `system_vm_size` | `string` | `"Standard_D2s_v3"` | VM size for nodes. |
| `enable_auto_scaling` | `bool` | `false` | Enable cluster autoscaler. |
| `min_count` | `number` | `1` | Minimum node count. |
| `max_count` | `number` | `5` | Maximum node count. |
| `enable_azure_rbac` | `bool` | `false` | Enable Azure RBAC for authorization. |
| `tags` | `map(string)` | `{}` | Tags to apply. |

#### Outputs

| Name | Description |
|---|---|
| `id` | Resource ID of the AKS cluster. |
| `name` | Name of the AKS cluster. |
| `kube_config_raw` | Raw kubeconfig (sensitive). |
| `principal_id` | Principal ID of the cluster's managed identity. |

---

### modules/acr

Creates an Azure Container Registry.

#### Usage

```hcl
module "acr" {
  source              = "../../modules/acr"
  name                = "acrmyappprod"
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  sku                 = "Standard"
  tags                = local.tags
}
```

#### Inputs

| Name | Type | Default | Description |
|---|---|---|---|
| `name` | `string` | — | Registry name (globally unique, alphanumeric). |
| `resource_group_name` | `string` | — | Name of the resource group. |
| `location` | `string` | — | Azure region. |
| `sku` | `string` | `"Standard"` | SKU: Basic, Standard, or Premium. |
| `admin_enabled` | `bool` | `false` | Enable admin user. |
| `georeplications` | `list(object)` | `[]` | Geo-replication locations (Premium only). |
| `tags` | `map(string)` | `{}` | Tags to apply. |

#### Outputs

| Name | Description |
|---|---|
| `id` | Resource ID of the registry. |
| `name` | Name of the registry. |
| `login_server` | Login server URL. |

---

### modules/keyvault

Creates an Azure Key Vault with RBAC authorization enabled by default.

#### Usage

```hcl
module "keyvault" {
  source              = "../../modules/keyvault"
  name                = "kv-my-app-prod-001"
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  sku_name            = "standard"
  tags                = local.tags
}
```

#### Inputs

| Name | Type | Default | Description |
|---|---|---|---|
| `name` | `string` | — | Key Vault name (3–24 chars, globally unique). |
| `resource_group_name` | `string` | — | Name of the resource group. |
| `location` | `string` | — | Azure region. |
| `sku_name` | `string` | `"standard"` | SKU: standard or premium. |
| `soft_delete_retention_days` | `number` | `90` | Days to retain soft-deleted items. |
| `purge_protection_enabled` | `bool` | `true` | Enable purge protection. |
| `enable_rbac_authorization` | `bool` | `true` | Use RBAC instead of access policies. |
| `network_acls` | `object` | `null` | Network ACL configuration. |
| `tags` | `map(string)` | `{}` | Tags to apply. |

#### Outputs

| Name | Description |
|---|---|
| `id` | Resource ID of the Key Vault. |
| `name` | Name of the Key Vault. |
| `vault_uri` | URI of the Key Vault. |

---

### modules/storage-account

Creates an Azure Storage Account with optional blob containers.

#### Usage

```hcl
module "storage" {
  source                          = "../../modules/storage-account"
  name                            = "stmyappdata001"
  resource_group_name             = module.resource_group.name
  location                        = module.resource_group.location
  account_tier                    = "Standard"
  account_replication_type        = "ZRS"
  allow_nested_items_to_be_public = false
  containers = [
    { name = "assets",  access_type = "private" },
    { name = "uploads", access_type = "private" },
  ]
  tags = local.tags
}
```

#### Inputs

| Name | Type | Default | Description |
|---|---|---|---|
| `name` | `string` | — | Storage account name (3–24 chars, lowercase alphanumeric). |
| `resource_group_name` | `string` | — | Name of the resource group. |
| `location` | `string` | — | Azure region. |
| `account_tier` | `string` | `"Standard"` | Standard or Premium. |
| `account_replication_type` | `string` | `"LRS"` | LRS, GRS, RAGRS, ZRS, GZRS, or RAGZRS. |
| `min_tls_version` | `string` | `"TLS1_2"` | Minimum TLS version. |
| `allow_nested_items_to_be_public` | `bool` | `false` | Allow blob public access. |
| `containers` | `list(object)` | `[]` | Containers with `name` and `access_type`. |
| `tags` | `map(string)` | `{}` | Tags to apply. |

#### Outputs

| Name | Description |
|---|---|
| `id` | Resource ID of the storage account. |
| `name` | Name of the storage account. |
| `primary_blob_endpoint` | Primary blob endpoint URL. |
| `primary_connection_string` | Primary connection string (sensitive). |

---

### modules/app-service

Creates a Linux App Service Plan and a Linux Web App with SystemAssigned identity.

#### Usage

```hcl
module "app_service" {
  source              = "../../modules/app-service"
  name                = "app-my-service"
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  sku_name            = "P1v3"
  linux_fx_version    = "NODE|18-lts"
  app_settings = {
    APPINSIGHTS_INSTRUMENTATIONKEY = module.monitoring.instrumentation_key
    DATABASE_URL                   = "..."
  }
  tags = local.tags
}
```

#### Inputs

| Name | Type | Default | Description |
|---|---|---|---|
| `name` | `string` | — | Name of the Web App. The plan is named `<name>-plan`. |
| `resource_group_name` | `string` | — | Name of the resource group. |
| `location` | `string` | — | Azure region. |
| `sku_name` | `string` | `"B1"` | App Service Plan SKU (e.g. B1, S1, P1v3). |
| `linux_fx_version` | `string` | `"NODE\|18-lts"` | Runtime stack (e.g. `NODE\|18-lts`, `PYTHON\|3.11`). |
| `app_settings` | `map(string)` | `{}` | Application settings (env vars). |
| `tags` | `map(string)` | `{}` | Tags to apply. |

#### Outputs

| Name | Description |
|---|---|
| `id` | Resource ID of the Web App. |
| `name` | Name of the Web App. |
| `default_hostname` | Default hostname. |
| `identity_principal_id` | Principal ID of the system-assigned identity. |
| `service_plan_id` | Resource ID of the App Service Plan. |

---

### modules/sql-database

Creates an Azure SQL Server (version 12.0) and a database. TLS 1.2 minimum is enforced.

#### Usage

```hcl
module "sql" {
  source              = "../../modules/sql-database"
  server_name         = "sql-my-app-prod"
  db_name             = "appdb"
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  admin_login         = "sqladmin"
  admin_password      = var.sql_admin_password
  db_sku_name         = "GP_S_Gen5_2"
  max_size_gb         = 64
  tags                = local.tags
}
```

#### Inputs

| Name | Type | Default | Description |
|---|---|---|---|
| `server_name` | `string` | — | SQL server name (globally unique). |
| `db_name` | `string` | — | Database name. |
| `resource_group_name` | `string` | — | Name of the resource group. |
| `location` | `string` | — | Azure region. |
| `admin_login` | `string` | `"sqladmin"` | Administrator login. |
| `admin_password` | `string` | — | Administrator password (sensitive). |
| `db_sku_name` | `string` | `"GP_S_Gen5_1"` | Database SKU (e.g. S0, GP_S_Gen5_1). |
| `max_size_gb` | `number` | `32` | Maximum database size in GB. |
| `aad_admin` | `object` | `null` | Azure AD administrator configuration. |
| `tags` | `map(string)` | `{}` | Tags to apply. |

#### Outputs

| Name | Description |
|---|---|
| `server_id` | Resource ID of the SQL server. |
| `server_fqdn` | Fully qualified domain name of the SQL server. |
| `database_id` | Resource ID of the database. |
| `database_name` | Name of the database. |

---

### modules/redis-cache

Creates an Azure Cache for Redis with SSL-only access and TLS 1.2 minimum.

#### Usage

```hcl
module "redis" {
  source              = "../../modules/redis-cache"
  name                = "redis-my-app-prod"
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  capacity            = 1
  family              = "C"
  sku_name            = "Standard"
  tags                = local.tags
}
```

#### Inputs

| Name | Type | Default | Description |
|---|---|---|---|
| `name` | `string` | — | Cache name (globally unique). |
| `resource_group_name` | `string` | — | Name of the resource group. |
| `location` | `string` | — | Azure region. |
| `capacity` | `number` | `1` | Cache size unit (0–6 for C family, 1–5 for P). |
| `family` | `string` | `"C"` | C (Basic/Standard) or P (Premium). |
| `sku_name` | `string` | `"Standard"` | Basic, Standard, or Premium. |
| `tags` | `map(string)` | `{}` | Tags to apply. |

#### Outputs

| Name | Description |
|---|---|
| `id` | Resource ID of the Redis Cache. |
| `hostname` | Cache endpoint hostname. |
| `ssl_port` | SSL port number. |
| `primary_access_key` | Primary access key (sensitive). |
| `primary_connection_string` | Primary connection string (sensitive). |

---

### modules/monitoring

Creates a Log Analytics workspace and a workspace-linked Application Insights component.

#### Usage

```hcl
module "monitoring" {
  source              = "../../modules/monitoring"
  workspace_name      = "log-my-app-prod"
  insights_name       = "appi-my-app-prod"
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  retention_in_days   = 90
  application_type    = "web"
  tags                = local.tags
}
```

#### Inputs

| Name | Type | Default | Description |
|---|---|---|---|
| `workspace_name` | `string` | — | Log Analytics workspace name. |
| `insights_name` | `string` | — | Application Insights component name. |
| `resource_group_name` | `string` | — | Name of the resource group. |
| `location` | `string` | — | Azure region. |
| `retention_in_days` | `number` | `30` | Log retention period (30–730 days). |
| `application_type` | `string` | `"web"` | Application type (web, ios, other, etc.). |
| `tags` | `map(string)` | `{}` | Tags to apply. |

#### Outputs

| Name | Description |
|---|---|
| `workspace_id` | Resource ID of the Log Analytics workspace. |
| `workspace_name` | Name of the workspace. |
| `insights_id` | Resource ID of the Application Insights component. |
| `insights_name` | Name of the Application Insights component. |
| `instrumentation_key` | Instrumentation key (sensitive). |
| `connection_string` | Application Insights connection string (sensitive). |

---

### modules/private-endpoint

Creates a Private Endpoint with an optional DNS zone group.

#### Usage

```hcl
module "private_endpoint" {
  source                         = "../../modules/private-endpoint"
  name                           = "pe-sql-my-app"
  resource_group_name            = module.resource_group.name
  location                       = module.resource_group.location
  subnet_id                      = module.vnet.subnet_ids["endpoints"]
  private_connection_resource_id = module.sql.server_id
  subresource_names              = ["sqlServer"]
  private_dns_zone_ids           = [azurerm_private_dns_zone.sql.id]
  tags                           = local.tags
}
```

#### Inputs

| Name | Type | Default | Description |
|---|---|---|---|
| `name` | `string` | — | Name of the private endpoint. |
| `resource_group_name` | `string` | — | Name of the resource group. |
| `location` | `string` | — | Azure region. |
| `subnet_id` | `string` | — | Subnet ID for the endpoint NIC. |
| `private_connection_resource_id` | `string` | — | Resource ID of the target service. |
| `subresource_names` | `list(string)` | — | Sub-resource names (e.g. `["blob"]`, `["sqlServer"]`). |
| `private_dns_zone_ids` | `list(string)` | `[]` | DNS zone IDs. Empty list skips DNS zone group creation. |
| `tags` | `map(string)` | `{}` | Tags to apply. |

#### Outputs

| Name | Description |
|---|---|
| `id` | Resource ID of the private endpoint. |
| `name` | Name of the private endpoint. |
| `private_ip_address` | Private IP address allocated to the endpoint. |

---

### modules/nsg

Creates a Network Security Group and its security rules.

#### Usage

```hcl
module "nsg" {
  source              = "../../modules/nsg"
  name                = "nsg-app-subnet"
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  rules = [
    {
      name                       = "AllowHTTPS"
      priority                   = 100
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "443"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    },
    {
      name                       = "DenyAll"
      priority                   = 4096
      direction                  = "Inbound"
      access                     = "Deny"
      protocol                   = "*"
      source_port_range          = "*"
      destination_port_range     = "*"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    },
  ]
  tags = local.tags
}
```

#### Inputs

| Name | Type | Default | Description |
|---|---|---|---|
| `name` | `string` | — | NSG name. |
| `resource_group_name` | `string` | — | Name of the resource group. |
| `location` | `string` | — | Azure region. |
| `rules` | `list(object)` | `[]` | List of security rules. See usage example for the object shape. |
| `tags` | `map(string)` | `{}` | Tags to apply. |

#### Outputs

| Name | Description |
|---|---|
| `id` | Resource ID of the NSG. |
| `name` | Name of the NSG. |

---

### modules/managed-identity

Creates a user-assigned Managed Identity.

#### Usage

```hcl
module "identity" {
  source              = "../../modules/managed-identity"
  name                = "id-my-app-prod"
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  tags                = local.tags
}

resource "azurerm_role_assignment" "identity_kv_reader" {
  scope                = module.keyvault.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = module.identity.principal_id
}
```

#### Inputs

| Name | Type | Default | Description |
|---|---|---|---|
| `name` | `string` | — | Identity name. |
| `resource_group_name` | `string` | — | Name of the resource group. |
| `location` | `string` | — | Azure region. |
| `tags` | `map(string)` | `{}` | Tags to apply. |

#### Outputs

| Name | Description |
|---|---|
| `id` | Resource ID of the managed identity. |
| `name` | Name of the identity. |
| `principal_id` | Service principal ID (used for role assignments). |
| `client_id` | Client ID. |
| `tenant_id` | Tenant ID. |

---

### modules/service-bus

Creates a Service Bus namespace with queues and topics.

#### Usage

```hcl
module "service_bus" {
  source              = "../../modules/service-bus"
  name                = "sb-my-app-prod"
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  sku                 = "Standard"
  queues = [
    { name = "orders",        enable_partitioning = true },
    { name = "notifications" },
  ]
  topics = [
    { name = "domain-events" },
  ]
  tags = local.tags
}
```

#### Inputs

| Name | Type | Default | Description |
|---|---|---|---|
| `name` | `string` | — | Namespace name (globally unique). |
| `resource_group_name` | `string` | — | Name of the resource group. |
| `location` | `string` | — | Azure region. |
| `sku` | `string` | `"Standard"` | Basic, Standard, or Premium. |
| `queues` | `list(object)` | `[]` | Queues with `name` and optional `enable_partitioning`. |
| `topics` | `list(object)` | `[]` | Topics with `name`. Requires Standard or Premium SKU. |
| `tags` | `map(string)` | `{}` | Tags to apply. |

#### Outputs

| Name | Description |
|---|---|
| `id` | Resource ID of the namespace. |
| `name` | Name of the namespace. |
| `endpoint` | Namespace endpoint. |
| `primary_connection_string` | Primary connection string (sensitive). |
| `queue_ids` | Map of queue name to resource ID. |
| `topic_ids` | Map of topic name to resource ID. |

---

### modules/cosmosdb

Creates a Cosmos DB account and optionally a SQL (Core) database when `kind = GlobalDocumentDB`.

#### Usage

```hcl
module "cosmosdb" {
  source              = "../../modules/cosmosdb"
  account_name        = "cosmos-my-app-prod"
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  kind                = "GlobalDocumentDB"
  consistency_policy = {
    consistency_level       = "Session"
    max_interval_in_seconds = 5
    max_staleness_prefix    = 100
  }
  geo_locations = [
    { location = "westeurope",  failover_priority = 0 },
    { location = "northeurope", failover_priority = 1 },
  ]
  sql_database_name = "myapp"
  tags              = local.tags
}
```

#### Inputs

| Name | Type | Default | Description |
|---|---|---|---|
| `account_name` | `string` | — | Account name (globally unique). |
| `resource_group_name` | `string` | — | Name of the resource group. |
| `location` | `string` | — | Azure region. |
| `kind` | `string` | `"GlobalDocumentDB"` | GlobalDocumentDB, MongoDB, or Parse. |
| `consistency_policy` | `object` | Session defaults | Consistency level and staleness settings. |
| `geo_locations` | `list(object)` | `null` | Geo-locations with `location` and `failover_priority`. |
| `sql_database_name` | `string` | `"main"` | SQL database name. Only applies when kind = GlobalDocumentDB. |
| `tags` | `map(string)` | `{}` | Tags to apply. |

#### Outputs

| Name | Description |
|---|---|
| `id` | Resource ID of the Cosmos DB account. |
| `name` | Name of the account. |
| `endpoint` | Document endpoint URL. |
| `primary_key` | Primary master key (sensitive). |
| `primary_connection_string` | Primary connection string (sensitive). |
| `sql_database_id` | Resource ID of the SQL database (null when kind is not GlobalDocumentDB). |

---

### modules/function-app

Creates a Linux Function App, its service plan, and the required backing storage account.

#### Usage

```hcl
module "function_app" {
  source              = "../../modules/function-app"
  name                = "func-my-processor"
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  sku_name            = "Y1"
  runtime = {
    name    = "python"
    version = "3.11"
  }
  app_settings = {
    SERVICE_BUS_CONNECTION  = module.service_bus.primary_connection_string
    COSMOS_ENDPOINT         = module.cosmosdb.endpoint
  }
  tags = local.tags
}
```

#### Inputs

| Name | Type | Default | Description |
|---|---|---|---|
| `name` | `string` | — | Function App name. The plan is named `<name>-plan`. |
| `resource_group_name` | `string` | — | Name of the resource group. |
| `location` | `string` | — | Azure region. |
| `sku_name` | `string` | `"Y1"` | Y1 (Consumption), EP1/EP2/EP3 (Elastic Premium). |
| `storage_account_name` | `string` | `null` | Override storage account name. |
| `runtime` | `object` | `{name="python", version="3.11"}` | Runtime with `name` (python/node/java/dotnet) and `version`. |
| `app_settings` | `map(string)` | `{}` | Application settings (env vars). |
| `tags` | `map(string)` | `{}` | Tags to apply. |

#### Outputs

| Name | Description |
|---|---|
| `id` | Resource ID of the Function App. |
| `name` | Name of the Function App. |
| `default_hostname` | Default hostname. |
| `principal_id` | Principal ID of the system-assigned identity. |

---

### modules/event-hub

Creates an Event Hub namespace and one or more Event Hubs.

#### Usage

```hcl
module "event_hub" {
  source              = "../../modules/event-hub"
  namespace_name      = "evhns-my-app-prod"
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  sku                 = "Standard"
  capacity            = 2
  event_hubs = [
    { name = "telemetry",  partition_count = 4, message_retention = 7 },
    { name = "audit-log",  partition_count = 2, message_retention = 1 },
  ]
  tags = local.tags
}
```

#### Inputs

| Name | Type | Default | Description |
|---|---|---|---|
| `namespace_name` | `string` | — | Namespace name (globally unique). |
| `resource_group_name` | `string` | — | Name of the resource group. |
| `location` | `string` | — | Azure region. |
| `sku` | `string` | `"Standard"` | Basic, Standard, or Premium. |
| `capacity` | `number` | `1` | Throughput units. |
| `event_hubs` | `list(object)` | `[]` | Hubs with `name`, `partition_count`, and `message_retention`. |
| `tags` | `map(string)` | `{}` | Tags to apply. |

#### Outputs

| Name | Description |
|---|---|
| `namespace_id` | Resource ID of the namespace. |
| `namespace_name` | Name of the namespace. |
| `event_hub_ids` | Map of Event Hub name to resource ID. |
| `primary_connection_string` | Primary connection string (sensitive). |

---

## Examples

### examples/aks-cluster

Provisions a production-ready AKS cluster with a dedicated VNet, ACR, and an ACR Pull role assignment for the cluster's managed identity. This is the minimal reference architecture for containerised workloads on Azure.

Components: resource-group, vnet, acr, aks.

```bash
cd examples/aks-cluster
terraform init
terraform plan
terraform apply
```

---

### examples/web-app

Provisions a full web application stack: resource group, VNet with dedicated subnets, Log Analytics + Application Insights, Key Vault, Storage Account, Azure SQL Database, Redis Cache, Linux App Service, and a private endpoint for the SQL server.

The monitoring instrumentation key is automatically passed as an application setting to the Web App so telemetry is wired up without manual configuration.

Components: resource-group, vnet, monitoring, keyvault, storage-account, sql-database, redis-cache, app-service, private-endpoint.

```bash
cd examples/web-app
terraform init
terraform plan -var="sql_admin_password=<secret>"
terraform apply -var="sql_admin_password=<secret>"
```

---

### examples/microservices

Provisions an AKS-based microservices platform: VNet, ACR, AKS (with ACR Pull role assignment), Log Analytics + Application Insights, Key Vault, Service Bus (with queues and topics for async messaging), and Cosmos DB (with a SQL database).

Components: resource-group, vnet, monitoring, keyvault, acr, aks, service-bus, cosmosdb.

```bash
cd examples/microservices
terraform init
terraform plan
terraform apply
```

---

### Running any example

All examples follow the same workflow:

```bash
# 1. Authenticate
az login
az account set --subscription "<your-subscription-id>"

# 2. Initialise providers and modules
terraform init

# 3. Preview changes
terraform plan

# 4. Apply
terraform apply

# 5. Destroy when done
terraform destroy
```

---

## Connecting modules

Modules are designed to be chained by passing outputs as inputs. Below are the most common patterns.

### VNet subnets into AKS

```hcl
module "vnet" {
  source        = "../../modules/vnet"
  address_space = ["10.0.0.0/16"]
  subnets = [
    { name = "aks-nodes", address_prefixes = ["10.0.1.0/24"] },
  ]
  # ...
}

module "aks" {
  source    = "../../modules/aks"
  subnet_id = module.vnet.subnet_ids["aks-nodes"]
  # ...
}
```

### Monitoring into App Service

```hcl
module "monitoring" {
  source = "../../modules/monitoring"
  # ...
}

module "app_service" {
  source = "../../modules/app-service"
  app_settings = {
    APPINSIGHTS_INSTRUMENTATIONKEY        = module.monitoring.instrumentation_key
    APPLICATIONINSIGHTS_CONNECTION_STRING = module.monitoring.connection_string
  }
  # ...
}
```

### App Service identity into Key Vault RBAC

```hcl
module "app_service" {
  source = "../../modules/app-service"
  # ...
}

resource "azurerm_role_assignment" "app_kv_secrets" {
  scope                = module.keyvault.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = module.app_service.identity_principal_id
}
```

### AKS identity into ACR

```hcl
module "acr" { source = "../../modules/acr" /* ... */ }
module "aks" { source = "../../modules/aks" /* ... */ }

resource "azurerm_role_assignment" "aks_acr_pull" {
  scope                = module.acr.id
  role_definition_name = "AcrPull"
  principal_id         = module.aks.principal_id
}
```

### Service Bus connection string into Function App

```hcl
module "service_bus" { source = "../../modules/service-bus" /* ... */ }

module "function_app" {
  source = "../../modules/function-app"
  app_settings = {
    SERVICE_BUS_CONNECTION_STRING = module.service_bus.primary_connection_string
  }
  # ...
}
```

---

## Tagging strategy

Define a shared `tags` local block in every configuration root and pass it to every module. This ensures consistent resource tagging across an entire environment.

```hcl
locals {
  tags = {
    environment = "production"
    project     = "my-app"
    owner       = "platform-team"
    managed_by  = "terraform"
    cost_centre = "CC-1234"
  }
}

module "resource_group" {
  source = "../../modules/resource-group"
  tags   = local.tags
  # ...
}

module "vnet" {
  source = "../../modules/vnet"
  tags   = local.tags
  # ...
}
```

Recommended tags:

| Tag | Purpose |
|---|---|
| `environment` | `development`, `staging`, `production` |
| `project` | Logical application or product name |
| `owner` | Team or individual responsible |
| `managed_by` | Always `terraform` for IaC-managed resources |
| `cost_centre` | Finance allocation code |

---

## CI — GitHub Actions

The `.github/workflows/validate.yml` workflow runs on every push to `main` and on all pull requests. It validates every module in parallel using a matrix strategy.

For each module the workflow runs:

1. `terraform fmt -check` — enforces consistent formatting.
2. `terraform init -backend=false` — downloads providers without configuring a backend.
3. `terraform validate` — checks that the configuration is syntactically and semantically valid.
4. `tflint` — runs linting rules for the AzureRM provider.

### Adding tflint rules

Create a `.tflint.hcl` file in the module directory or at the repository root:

```hcl
plugin "azurerm" {
  enabled = true
  version = "0.27.0"
  source  = "github.com/terraform-linters/tflint-ruleset-azurerm"
}

rule "azurerm_resource_missing_tags" {
  enabled = true
  tags    = ["environment", "managed_by"]
}
```

---

## Contributing

### Adding a new module

1. Create `modules/<your-module>/` with four files: `main.tf`, `variables.tf`, `outputs.tf`, `versions.tf`.
2. Follow the conventions in existing modules:
   - Name the primary resource `this`.
   - Add a `description` to every `variable` and `output`.
   - Add a `tags` variable of type `map(string)` with `default = {}`.
   - Use `versions.tf` with `required_version = ">= 1.3.0"` and `azurerm >= 3.0.0`.
3. Add the module path to the `matrix.module` list in `.github/workflows/validate.yml`.
4. Add a section to the [Module catalog](#module-catalog) table and a full [Module reference](#module-reference) entry in this README.
5. Run `terraform fmt -recursive modules/<your-module>` before opening a pull request.

### Module checklist

- [ ] `main.tf` — resources with no hard-coded values
- [ ] `variables.tf` — all inputs declared with `type`, `description`, and appropriate `default`
- [ ] `outputs.tf` — all useful attributes exposed; sensitive outputs marked `sensitive = true`
- [ ] `versions.tf` — standard provider constraints
- [ ] Added to `.github/workflows/validate.yml` matrix
- [ ] Added to `README.md` module catalog and reference section
- [ ] `terraform fmt` passes
- [ ] `terraform validate` passes
