# terraform-infrastructure-live

Sample project inspired from https://blog.gruntwork.io/how-to-create-reusable-infrastructure-with-terraform-modules-25526d65f73d https://github.com/gruntwork-io/terragrunt-infrastructure-live-example https://medium.com/@kief/https-medium-com-kief-using-pipelines-to-manage-environments-with-infrastructure-as-code-b37285a1cbf5
Running on Google GCE. 

Use scripts/bootstrap.sh to bootstrap your environment.

Go to gce_account and runt terragrunt plan-all and if everything seems fine run terragrunt apply-all

 cd gce_account
 terragrunt plan-all
 terragrunt apply-all
 