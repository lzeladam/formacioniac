variable "agent_count" {
  default = 3
}

variable "cluster_name" {
}

variable "dns_prefix" {
}

variable "ssh_public_key" {
  default = "~/.ssh/id_rsa.pub"
}

variable "identity_ids" {
  type        = list(string)
  description = "(Optional) Specifies a list of User Assigned Managed Identity IDs to be assigned to this Kubernetes Cluster."
  default     = null
}

variable "acr_name" {
  description = "Nombre del Azure Container Registry"
  default     = "myacrk8sgr"
}

variable "azurerm_resource_group" {
}
