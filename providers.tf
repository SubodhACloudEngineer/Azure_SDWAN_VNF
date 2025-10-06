terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.0"
    }
  }
}

provider "azurerm" {
  features {}
  use_cli                         = true
  tenant_id                       = "75d69b80-844c-4077-b28a-cf2b59cc5187"
  subscription_id                 = "8527d19f-1ff6-461c-a89e-da961a355bed"
  resource_provider_registrations = "none"
}
