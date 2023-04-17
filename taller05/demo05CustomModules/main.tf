module "aad" {
  source = "./modules/aad"
}

module "network" {
  source = "./modules/network"
  azurerm_resource_group = var.azurerm_resource_group
}

module "dns" {
  source = "./modules/dns"
  azurerm_resource_group = var.azurerm_resource_group
}

module "identity" {
  source = "./modules/identity"
  private_dns_zone_id = module.dns.private_dns_zone_id
  azurerm_resource_group = var.azurerm_resource_group
}

module "kubernetes" {
  source = "./modules/kubernetes"
  azurerm_resource_group = var.azurerm_resource_group
  cluster_name  = var.cluster_name
  dns_prefix    = var.dns_prefix
  ssh_public_key = var.ssh_public_key
  application_subnet_id = module.network.application_subnet_id
  database_subnet_id    = module.network.database_subnet_id
  identity_ids = module.identity.main_identity_id
  private_dns_zone_id = module.dns.private_dns_zone_id
  k8sadmins_object_id = module.aad.k8sadmins_object_id
}

module "container_registry" {
  source = "./modules/container_registry"
  acr_name = var.acr_name
  azurerm_resource_group = var.azurerm_resource_group
}

