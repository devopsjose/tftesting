
resource "azurerm_virtual_network" "vmss-build-agent" {
  name                = var.vnet_name
  resource_group_name = azurerm_resource_group.vmss-build-agent.name
  location            = var.region
  address_space       = ["10.0.2.0/25"] # 10.0.2.0 - 10.0.2.127
}

resource "azurerm_subnet" "vmss-build-agent" {
  name                 = var.subnet_name
  resource_group_name  = azurerm_resource_group.vmss-build-agent.name
  virtual_network_name = azurerm_virtual_network.vmss-build-agent.name
  address_prefixes     = ["10.0.2.0/26"] # 10.0.2.0 - 10.0.2.63
}

 resource "azurerm_subnet" "elf-vmss-build-agent" {
   name                 = "elf-vmss-build-agent"
   resource_group_name  = azurerm_resource_group.vmss-build-agent.name
   virtual_network_name = azurerm_virtual_network.vmss-build-agent.name
   address_prefixes     = ["10.0.2.64/26"] # 10.0.2.64 - 10.0.2.127
 }

resource "random_password" "vmss-build-agent" {
  length      = 16
  special     = false
  min_lower   = 1
  min_upper   = 1
  min_numeric = 1
}

resource "azurerm_key_vault" "vmss-build-agent" {
  name                       = "ed-vmss-build-agent"
  location                   = var.region
  resource_group_name        = azurerm_resource_group.vmss-build-agent.name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "premium"
  soft_delete_retention_days = 7

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions = [
      "Create",
      "Get",
    ]

    secret_permissions = [
      "Set",
      "Get",
      "Delete",
      "Purge",
      "Recover"
    ]
  }
  lifecycle {
    ignore_changes = [
      access_policy,
    ]
  }
}

resource "azurerm_key_vault_secret" "vmss-build-agent" {
  name         = "admin-password"
  value        = random_password.vmss-build-agent.result
  key_vault_id = azurerm_key_vault.vmss-build-agent.id
}

resource "azurerm_windows_virtual_machine_scale_set" "dev-elf-vmss-build-agent" {
  name                        = "dev-elf-vmss-build-agent"
  computer_name_prefix        = "edmentum"
  resource_group_name         = azurerm_resource_group.vmss-build-agent.name
  location                    = var.region
  sku                         = "Standard_E8bds_v5"
  instances                   = 0
  admin_username              = "adminuser"
  admin_password              = random_password.vmss-build-agent.result
  overprovision               = false
  single_placement_group      = false
  platform_fault_domain_count = 0
  source_image_id             = "/subscriptions/144d2212-24c3-4bf6-8ebf-b6a70b110730/resourceGroups/vmss-build-agent/providers/Microsoft.Compute/galleries/${azurerm_shared_image_gallery.vmss-build-agent.name}/images/${var.image_name}/versions/${var.dev_image_version}"
  # source_image_id             = "/subscriptions/144d2212-24c3-4bf6-8ebf-b6a70b11073/resourceGroups/vmss-build-agent/providers/Microsoft.Compute/images/elf-vmss-build-agent"

  os_disk {
    storage_account_type = "Premium_LRS"
    caching              = "ReadOnly"
  }

  network_interface {
    name                          = "dev-elf-vmss-build-agent"
    primary                       = true
    enable_accelerated_networking = true

    ip_configuration {
      name      = "internal"
      primary   = true
      subnet_id = azurerm_subnet.vmss-build-agent.id
    }
  }

  lifecycle {
    ignore_changes = [
      platform_fault_domain_count,
      instances,
      tags["__AzureDevOpsElasticPool"],
      tags["__AzureDevOpsElasticPoolTimeStamp"],
    ]
  }
}

 resource "azurerm_windows_virtual_machine_scale_set" "elf-vmss-build-agent" {
   name                        = "elf-vmss-build-agent"
   computer_name_prefix        = "edmentum"
   resource_group_name         = azurerm_resource_group.vmss-build-agent.name
   location                    = var.region
   sku                         = "Standard_E8bds_v5"
   instances                   = 0
   admin_username              = "adminuser"
   admin_password              = random_password.vmss-build-agent.result
   overprovision               = false
   single_placement_group      = false
   platform_fault_domain_count = 0
   source_image_id             = "/subscriptions/144d2212-24c3-4bf6-8ebf-b6a70b110730/resourceGroups/vmss-build-agent/providers/Microsoft.Compute/galleries/${azurerm_shared_image_gallery.vmss-build-agent.name}/images/${var.image_name}/versions/${var.prod_image_version}"
  #  source_image_id             = "/subscriptions/144d2212-24c3-4bf6-8ebf-b6a70b110730/resourceGroups/vmss-build-agent/providers/Microsoft.Compute/images/elf-vmss-build-agent"

   os_disk {
     storage_account_type = "Premium_LRS"
     caching              = "ReadOnly"
   }

   network_interface {
     name                          = "elf-vmss-build-agent"
     primary                       = true
     enable_accelerated_networking = true

     ip_configuration {
       name      = "internal"
       primary   = true
       subnet_id = azurerm_subnet.elf-vmss-build-agent.id
     }
   }

   lifecycle {
     ignore_changes = [
       platform_fault_domain_count,
       instances,
       tags["__AzureDevOpsElasticPool"],
       tags["__AzureDevOpsElasticPoolTimeStamp"],
     ]
   }
 }

# data "azurerm_subscription" "current" {
# }
