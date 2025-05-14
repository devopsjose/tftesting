# resource "azurerm_subnet" "bastion" {
#   name                 = "AzureBastionSubnet"
#   resource_group_name  = azurerm_resource_group.vmss-build-agent.name
#   virtual_network_name = azurerm_virtual_network.vmss-build-agent.name
#   address_prefixes     = ["10.0.2.64/27"]
# }

# resource "azurerm_public_ip" "bastion" {
#   name                = "bastionpip"
#   location            = var.region
#   resource_group_name = azurerm_resource_group.vmss-build-agent.name
#   allocation_method   = "Static"
#   sku                 = "Standard"
# }

# resource "azurerm_bastion_host" "bastion" {
#   name                = "vmss-agent-bastion"
#   location            = var.region
#   resource_group_name = azurerm_resource_group.vmss-build-agent.name

#   ip_configuration {
#     name                 = "configuration"
#     subnet_id            = azurerm_subnet.bastion.id
#     public_ip_address_id = azurerm_public_ip.bastion.id
#   }
# }