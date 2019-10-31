bootstrap.sh is a sample script to bootstrap the Azure environment in this repo.

Requirement
az # Azure cli from microsoft
terraform # Terrafrom from hashicorp
terragrunt # From gruntwork

The bootstrap.sh files first tries to login to the azure environment, and then create a service principal to be used by terraform later. It creates an `azure/sourceme.sh` in the top three. 
After that it uses terraform to create a resource group and a storage user to store the terraform state in and add that information to `azure/somefile`
