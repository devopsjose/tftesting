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
    resource_group_name  = "tfstate-rg"
    storage_account_name = "tfstatestorageacct2"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
  }
}

data "azurerm_client_config" "current" {
}
