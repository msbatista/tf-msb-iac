terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "2.85"
    }
  }

  backend "azurerm" {

  }
}

provider "azurerm" {
  skip_provider_registration = true
  features {

  }
}
