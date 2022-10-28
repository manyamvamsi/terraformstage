terraform {
  backend "azurerm" {
    resource_group_name = "prodserver"
    storage_account_name = "prodstorage"
    container_name = "cont"
    key = "terraform.cont"
    access_key = "terraformisainfracreationwhichitmakesourjobveryeasywhiledeployinservers=="
  }
}
provider "azurerm" {
    features {
      
    }
    subscription_id = "yuhavetoprovideprovidersubscriptionid"
    client_id = "clientidhavetomentioninthisarea"
    client_secret = "secretidistomentioninthissection"
    tenant_id = "dropthetenantidoftheprovider"
}
resource "azurerm_resource_group" "rs1" {
    name = "devresource"
    location = "East US"
    tags = {
      "name" = "resource"
    }
}
resource "azurerm_virtual_network" "vnet1" {
    name = "devvnet"
    resource_group_name = azurerm_resource_group.rs1.name
    location = azurerm_resource_group.rs1.location
    address_space = [ "10.60.0.0/24" ]
}
resource "azurerm_subnet" "devsubnet1" {
    name = "devsubnet"
    resource_group_name = azurerm_resource_group.rs1.name
    virtual_network_name = azurerm_virtual_network.vnet1.name
    address_prefixes = [ "10.60.1.0/16" ]
}
resource "azurerm_public_ip" "pubip1" {
    name = "pubip"
    resource_group_name = azurerm_resource_group.rs1.name
    location = azurerm_resource_group.rs1.location
    allocation_method = "Static"
}
resource "azurerm_network_interface" "nic1" {
    name = "nic"
    resource_group_name = azurerm_resource_group.rs1.name
    location = azurerm_resource_group.rs1.location
    ip_configuration {
      name = "pconf"
      subnet_id = azurerm_subnet.devsubnet1.id
      private_ip_address_allocation = "Dynamic"
      public_ip_address_id = azurerm_public_ip.pubip1.id
    }
}
resource "azurerm_linux_virtual_machine" "vm1" {
    name = "devserver"
    resource_group_name = azurerm_resource_group.rs1.name
    location = azurerm_resource_group.rs1.location
    size = "standard_F2"
    admin_username = "maduser"
    network_interface_ids = [azurerm_network_interface.nic1.id]
    admin_ssh_key {
      username = "maduser" 
      public_key = ("~/.ssh/id_rsa.pub")
    }  
    os_disk {
      caching = "ReadWrite"
      storage_account_type = "Standard_LRS"
    }
    source_image_reference {
      publisher = "Canonical"
      offer = "UbuntuServer"
      sku = "18.04-LTS"
      version = "latest"
    }
}
resource "azurerm_app_service_plan" "plan1" {
    name = "appplan"
    resource_group_name = azurerm_resource_group.rs1.name
    location = azurerm_resource_group.rs1.location
    sku {
      tier = "Standard"
      size = "S1"
    }
    depends_on = [
      azurerm_resource_group.rs1
    ]
}
resource "azurerm_app_service" "app1" {
  name = "webapp"
  resource_group_name = azurerm_resource_group.rs1.name
  location = azurerm_resource_group.rs1.location
  app_service_plan_id = azurerm_app_service_plan.plan1.id
  depends_on = [
    azurerm_app_service_plan.plan1
  ]
}

# storage account
resource "azurerm_storage_account" "devstorage1" {
  name = "devstoarage"
  resource_group_name = azurerm_resource_group.rs1.name
  location = azurerm_resource_group.rs1.location
  account_tier = "Standard"
  account_replication_type = "LRS"
  network_rules {
    default_action = "Deny"
    ip_rules = [ "10.60.1.0/16" ]
    virtual_network_subnet_ids = [azurerm_subnet.devsubnet1.id]
  }
  tags = {
    "name" = "storage"
  }
 
}