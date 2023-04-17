data "azurerm_resource_group" "rg" {
  name = var.azurerm_resource_group
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
    identity_ids = [var.identity_ids]
  }

  azure_active_directory_role_based_access_control {
    admin_group_object_ids = [var.k8sadmins_object_id]
    managed                = true
  }


  private_dns_zone_id     = var.private_dns_zone_id
  private_cluster_enabled = true

  default_node_pool {
    name                = "apppool"
    vm_size             = "Standard_D2_v2"
    vnet_subnet_id      = var.application_subnet_id
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

}

resource "azurerm_kubernetes_cluster_node_pool" "dbpool" {
  name                  = "dbpool"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.k8s.id
  vm_size               = "Standard_DS2_v2"
  vnet_subnet_id      = var.database_subnet_id
  enable_auto_scaling = true
  zones               = ["1", "3"]
  max_count           = 2
  min_count           = 1
  tags = {
    Environment = "Database"
  }
  depends_on = [azurerm_kubernetes_cluster.k8s]
}




