variable "prefix" {
  default = "taller04"
}

variable "agent_count" {
  default = 3
}

variable "cluster_name" {
  default = "k8stest"
}

variable "dns_prefix" {
  default = "k8stest"
}

variable "ssh_public_key" {
  default = "~/.ssh/id_rsa.pub"
}

variable "identity_ids" {
}

variable "private_dns_zone_id" {
}

variable "k8sadmins_object_id" {
}

variable "acr_name" {
  description = "Nombre del Azure Container Registry"
  default     = "myacrk8sgr"
}

variable "virtual_network_name" {
  description = "Nombre de la virtual netwrork"
  default     = "demo04-vn"
}

variable "application_subnet_id" {
}


variable "database_subnet_id" {
}

variable "azurerm_resource_group" {
}
