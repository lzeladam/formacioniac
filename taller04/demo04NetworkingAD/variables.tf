variable "prefix" {
  default = "taller04"
}

variable "agent_count" {
  default = 3
}

# The following two variable declarations are placeholder references.
# Set the values for these variable in taller04.tfvars
variable "aks_service_principal_app_id" {
  default = ""
}

variable "aks_service_principal_client_secret" {
  default = ""
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
  type        = list(string)
  description = "(Optional) Specifies a list of User Assigned Managed Identity IDs to be assigned to this Kubernetes Cluster."
  default     = null
}

variable "acr_name" {
  description = "Nombre del Azure Container Registry"
  default     = "myacrk8sgr"
}