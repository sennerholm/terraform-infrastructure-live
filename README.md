# terraform-infrastructure-live

Sample project inspired from https://blog.gruntwork.io/how-to-create-reusable-infrastructure-with-terraform-modules-25526d65f73d https://github.com/gruntwork-io/terragrunt-infrastructure-live-example 
https://medium.com/@kief/https-medium-com-kief-using-pipelines-to-manage-environments-with-infrastructure-as-code-b37285a1cbf5

Running on Google GCE or Azure.
* gce_account Old repo, not upgraded to new Terraform/Terragrunt
* gce_multiple Sample repo with VotingService running in GKE and Google Redis
* Azure Sample repo with VotingService and Redis Containers running in Azure Kubernetes 

## Required prereq gce_multiple

### Google Account
First, register a new account at google with your own email
https://accounts.google.com/SignUpWithoutGmail

### GCE account
Go to: https://cloud.google.com/compute/docs/signup and click on "Try it free"
to create a new GCE account, this will require your credit card information
although you will not be billed anything.

## Running

### Once
Use `bootstrap/gce_multiple/bootstrap.sh` to bootstrap your environment. It creates a new google project and ensure that you have everything enabled and installed. 

### Get your environment running and up to date!

When you have run the bootstrap do the following to get an environment, it also creates a file you could source to get the right ENVs. To get the environment upp and running

```
 cd gce_multiple
 terragrunt apply-all
```

## How to develop

Fork, clone and run

When developing a module use something like this to use the new module (in this example vote-terraform)

```
  terragrunt apply --terragrunt-source ~/git/terraform-infrastructure-modules/gce/vote-terraform
```