terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.50.0"
    }
    gitlab = {
      source  = "gitlabhq/gitlab"
      version = "15.9.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.15.0"
    }
  }
  backend "azurerm" {
    resource_group_name  = "GR_LABS"
    storage_account_name = "backendtfsate"
    container_name       = "tfstate"
    key                  = "demoaks.tfstate"
  }
}

# Configure the AZURE Provider
provider "azurerm" {
  features {}
}

# Datos de resource group AZURE
data "azurerm_resource_group" "rg" {
  name = "GR_LABS"
}

# Datos de usuario Azure Active Directory (AAD)
data "azuread_user" "aad" {
  mail_nickname = "alexander.zelada_outlook.com#EXT#"
}

# Grupo de Azure Active Directory (AAD)
resource "azuread_group" "k8sadmins" {
  display_name = "Kubernetes Admins"
  members = [
    data.azuread_user.aad.object_id,
  ]
  security_enabled = true
}

# Identidad asignada por usuario de AZURE
resource "azurerm_user_assigned_identity" "main" {
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location

  name = "identity-demo04-example"
}

# Subred AZURE
resource "azurerm_virtual_network" "test" {
  address_space       = ["10.52.0.0/16"]
  location            = data.azurerm_resource_group.rg.location
  name                = "demo04-vn"
  resource_group_name = data.azurerm_resource_group.rg.name
}

# Subred AZURE
resource "azurerm_subnet" "test" {
  address_prefixes                          = ["10.52.0.0/24"]
  name                                      = "subnet-sn"
  resource_group_name                       = data.azurerm_resource_group.rg.name
  virtual_network_name                      = azurerm_virtual_network.test.name
  private_endpoint_network_policies_enabled = true
}

# Zona de DNS privada AZURE
resource "azurerm_private_dns_zone" "main" {
  name                = "private.eastus2.azmk8s.io"
  resource_group_name = data.azurerm_resource_group.rg.name
}

# Asignación de rol de AZURE (contribuyente de red)
resource "azurerm_role_assignment" "network" {
  scope                = data.azurerm_resource_group.rg.id
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_user_assigned_identity.main.principal_id
}

# Asignación de rol de AZURE (contribuyente de zona DNS privada)
resource "azurerm_role_assignment" "dns" {
  scope                = azurerm_private_dns_zone.main.id
  role_definition_name = "Private DNS Zone Contributor"
  principal_id         = azurerm_user_assigned_identity.main.principal_id
}

# Cluster de Kubernetes AZURE
resource "azurerm_kubernetes_cluster" "k8s" {
  location            = data.azurerm_resource_group.rg.location
  name                = var.cluster_name
  resource_group_name = data.azurerm_resource_group.rg.name
  dns_prefix          = var.dns_prefix
  tags = {
    Environment = "Development"
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.main.id]
  }

  azure_active_directory_role_based_access_control {
    admin_group_object_ids = [azuread_group.k8sadmins.object_id]
    managed                = true
  }


  private_dns_zone_id     = azurerm_private_dns_zone.main.id
  private_cluster_enabled = true

  default_node_pool {
    name                = "agentpool"
    vm_size             = "Standard_D2_v2"
    node_count          = var.agent_count
    vnet_subnet_id      = azurerm_subnet.test.id
    enable_auto_scaling = true
    zones               = ["1", "3"]
    max_count           = 3
    min_count           = 1
  }
  linux_profile {
    admin_username = "ubuntu"

    ssh_key {
      key_data = file(var.ssh_public_key)
    }
  }
  network_profile {
    network_plugin    = "kubenet"
    load_balancer_sku = "standard"
  }
  /*  service_principal {
    client_id     = var.aks_service_principal_app_id
    client_secret = var.aks_service_principal_client_secret
  }
  */
}