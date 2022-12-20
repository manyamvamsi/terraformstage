terraform {
  backend "azurerm"{
    resource_group_name = "agarwood"
    storage_account_name = "agar112"
    container_name = "agarstore"
    key = "terraform.agarstore"
    access_key = "gnC5pL7P7G6YiCE/MVTKAT9usFd0BZMf8B0sRas0hf86VJYD2H5jD9nX9UJHvMGwXZBTvP8T/5GH+AStsWU89Q=="

  }
}


provider "azurerm" {
    features {
      
    }
    subscription_id = var.subscription_id
    client_id = var.client_id
    tenant_id = var.tenant_id
    client_secret = var.client_secret
}
locals {
  setup_name = "practice-hyd"
}

resource "azurerm_resource_group" "webapprg1" {
  name = "webapp988"
  location = "East US"
  tags = {
    "name" = "${local.setup_name}-rsg"
  }  
}

resource "azurerm_app_service_plan" "appplan11" {
  name = "appplandev1"
  location = azurerm_resource_group.webapprg1.location
  resource_group_name = azurerm_resource_group.webapprg1.name
  sku {
    tier = "standard"
    size = "S1"
  }
  tags = {
    "name" = "${local.setup_name}-applan"
  }
  depends_on = [
    azurerm_resource_group.webapprg1
  ]
}

resource "azurerm_app_service" "webapp1" {
  name = "webappdev1"
  location = azurerm_resource_group.webapprg1.location
  resource_group_name = azurerm_resource_group.webapprg1.name
  app_service_plan_id = azurerm_app_service_plan.appplan11.id
  tags = {
    "name" = "${local.setup_name}-webapp"
  }
  depends_on = [
    azurerm_app_service_plan.appplan11
  ]
}
