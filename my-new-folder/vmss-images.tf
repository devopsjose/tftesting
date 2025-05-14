resource "azurerm_resource_group" "vmss-build-agent" {
  name     = var.resource_group_name
  location = "eastus"
}

resource "azurerm_shared_image_gallery" "vmss-build-agent" {
  name                = "edmentumvmssbuildagent"
  resource_group_name = azurerm_resource_group.vmss-build-agent.name
  location            = var.region
  description         = "Shared images for vmss build agents"
}

resource "azurerm_shared_image" "vmss-build-agent" {
  name                = "elf-vmss-build-agent"
  gallery_name        = azurerm_shared_image_gallery.vmss-build-agent.name
  resource_group_name = azurerm_resource_group.vmss-build-agent.name
  location            = var.region
  os_type             = "Windows"

  identifier {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-Datacenter"
  }

}

//  resource "azurerm_shared_image_gallery" "elf-vmss-build-agent" {
//    name                = "elfvmssbuildagent"
//    resource_group_name = azurerm_resource_group.vmss-build-agent.name
//    location            = var.region
//    description         = "Shared images for vmss build agents"
//  }

//  resource "azurerm_shared_image" "elf-vmss-build-agent" {
//    name                = "elf-vmss-build-agent"
//    gallery_name        = azurerm_shared_image_gallery.elf-vmss-build-agent.name
//    resource_group_name = azurerm_resource_group.vmss-build-agent.name
//    location            = var.region
//    os_type             = "Windows"

//    identifier {
//      publisher = "MicrosoftWindowsServer"
//      offer     = "WindowsServer"
//      sku       = "2022-Datacenter"
//    }

//  }

# https://msftplayground.com/2021/02/private-azure-devops-agent-pool-based-the-microsoft-hosted-agents/

# https://github.com/actions/virtual-environments
