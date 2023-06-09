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
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.19.0"
    }
  }
  backend "azurerm" {
    resource_group_name  = "GR_LABS"
    storage_account_name = "backendtfsate"
    container_name       = "tfstate"
    key                  = "demoaksad.tfstate"
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

provider "kubernetes" {
  # Configura el proveedor de Kubernetes utilizando el contexto del clúster creado en azurerm_kubernetes_cluster
  config_path = azurerm_kubernetes_cluster.k8s.kube_config_raw
}

# Datos de usuario Azure Active Directory (AAD)
# Utiliza "azuread" de Terraform para buscar información sobre un usuario en Azure Active Directory (AAD).
# Un usuario con el valor de "mail_nickname" igual a "alexander.zelada_outlook.com#EXT#"
data "azuread_user" "aad" {
  mail_nickname = "alexander.zelada_outlook.com#EXT#"
}

# Grupo de Azure Active Directory (AAD)
# Se crea un grupo en Azure Active Directory (AAD) llamado "Kubernetes Admins"
# Y se agrega un miembro, el que se especifica en el mail_nickname
resource "azuread_group" "k8sadmins" {
  display_name = "Kubernetes Admins"
  members = [
    data.azuread_user.aad.object_id,
  ]
  security_enabled = true
}

# Identidad asignada por usuario de AZURE
# En términos simples, una identidad de usuario en Azure es un objeto que representa a un usuario 
# o a una aplicación en una instancia de Azure
resource "azurerm_user_assigned_identity" "main" {
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location

  name = "identity-demo04-example"
}

# Subred AZURE
resource "azurerm_virtual_network" "demo04_vn" {
  address_space       = ["10.52.0.0/16"]
  location            = data.azurerm_resource_group.rg.location
  name                = "demo04-vn"
  resource_group_name = data.azurerm_resource_group.rg.name
}

# Subred AZURE
resource "azurerm_subnet" "application" {
  address_prefixes                          = ["10.52.0.0/24"]
  name                                      = "application-sn"
  resource_group_name                       = data.azurerm_resource_group.rg.name
  virtual_network_name                      = azurerm_virtual_network.demo04_vn.name
  private_endpoint_network_policies_enabled = true
}

resource "azurerm_subnet" "database" {
  address_prefixes                          = ["10.52.1.0/24"]
  name                                      = "database-sn"
  resource_group_name                       = data.azurerm_resource_group.rg.name
  virtual_network_name                      = azurerm_virtual_network.demo04_vn.name
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
    name                = "apppool"
    vm_size             = "Standard_D2_v2"
    vnet_subnet_id      = azurerm_subnet.application.id
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

resource "azurerm_kubernetes_cluster_node_pool" "dbpool" {
  name                  = "dbpool"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.k8s.id
  vm_size               = "Standard_DS2_v2"
  vnet_subnet_id      = azurerm_subnet.database.id
  enable_auto_scaling = true
  zones               = ["1", "3"]
  max_count           = 2
  min_count           = 1
  tags = {
    Environment = "Database"
  }
  depends_on = [azurerm_kubernetes_cluster.k8s]
}


# Crear un Azure Container Registry básico
resource "azurerm_container_registry" "acr" {
  name                     = var.acr_name
  resource_group_name      = data.azurerm_resource_group.rg.name
  location                 = data.azurerm_resource_group.rg.location
  sku                      = "Basic"
  admin_enabled            = true
}

resource "kubernetes_secret" "acr" {
  depends_on = [azurerm_container_registry.acr]

  metadata {
    name = "acr-auth"
  }

  data = {
    username      = azurerm_container_registry.acr.admin_username
    password      = azurerm_container_registry.acr.admin_password
  }

  type = "kubernetes.io/dockerconfigjson"
}