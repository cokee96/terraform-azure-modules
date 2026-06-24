# terraform-azure-modules

Reusable Terraform modules for Azure infrastructure, following consistent naming and tagging conventions.

## Modules

| Module | Description |
|--------|-------------|
| [resource-group](modules/resource-group/) | Azure Resource Group |
| [vnet](modules/vnet/) | Virtual Network with subnets |
| [aks](modules/aks/) | Azure Kubernetes Service cluster |
| [acr](modules/acr/) | Azure Container Registry |
| [keyvault](modules/keyvault/) | Azure Key Vault |

## Requirements

- Terraform >= 1.3.0
- Azure provider >= 3.0.0

## Usage

Each module exposes `name`, `location`, `resource_group_name`, and `tags` as common inputs. See each module's `variables.tf` for the full list.

```hcl
module "resource_group" {
  source   = "github.com/cokee96/terraform-azure-modules//modules/resource-group"
  name     = "rg-myapp-prod"
  location = "westeurope"
  tags     = { environment = "prod", managed_by = "terraform" }
}
```

## Example

A complete AKS cluster with ACR, VNet, and resource group is in [examples/aks-cluster](examples/aks-cluster/).

## CI

Every pull request runs `terraform fmt`, `terraform validate`, and `tflint` against each module via GitHub Actions.
