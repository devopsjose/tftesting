terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=4.4.0"
    }
  }
}
provider "azurerm" {
  # use_msi = true
  # use_oidc = true
  # use_cli = true
  features {}
}
provider "random" {
}
terraform {
  backend "azurerm" {
    resource_group_name  = "terraform-state"
    storage_account_name = "edmentumtfstate"
    container_name       = "infra-adoagent-azss"
    key                  = "vmss-build-agent"
  }
}

data "azurerm_client_config" "current" {
}