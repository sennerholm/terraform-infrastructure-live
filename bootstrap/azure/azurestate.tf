provider "azurerm" {
  version = "~>1.5"
}

# Trying to setup "Set up Azure storage to store Terraform state" part of
# https://docs.microsoft.com/sv-se/azure/terraform/terraform-create-k8s-cluster-with-tf-and-aks

resource "azurerm_resource_group" "state" {
  name     = "terragrunt_state"
  location = "WestEurope"
}

resource "azurerm_storage_account" "account" {
  name                     = "terragrunt"
  resource_group_name      = "${azurerm_resource_group.state.name}"
  location                 = "${azurerm_resource_group.state.location}"
  account_tier             = "Standard"
  account_replication_type = "GRS"

  tags = {
    application    = "terragrunt"
    infrastructure = "true"
  }
}

resource "azurerm_storage_container" "container" {
  name                  = "tfstate"
  storage_account_name  = "${azurerm_storage_account.account.name}"
  container_access_type = "private"
}


output "storage_account_name" {
  value       = "${azurerm_storage_account.account.name}"
  description = "The AzureStorageAccountName"
}

resource "local_file" "export_vars" {
  count    = "1"
  filename = "../../azure/sourceme.terraform.sh"

  content = <<EOT
export ARM_ACCESS_KEY="${azurerm_storage_account.account.primary_access_key}"
EOT
}

output "storage_account_key" {
  value       = "${azurerm_storage_account.account.primary_access_key}"
  description = "The AzureStorageAccountKey (primary)"
}

output "storage_container" {
  value       = "${azurerm_storage_container.container.name}"
  description = "The name of the container to use"
}
