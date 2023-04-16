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
    key                  = "demo05.tfstate"
  }
}

provider "azurerm" {
  features {}
}