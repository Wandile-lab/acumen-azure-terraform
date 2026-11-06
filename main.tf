terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
  backend "azurerm" {
    resource_group_name  = "rg-acumen-cloudshell"
    storage_account_name = "stacumentfstate3025"
    container_name       = "tfstate"
    key                  = "acumen.terraform.tfstate"
    use_azuread_auth     = true
  }
}

provider "azurerm" {
  features {}
}
