# terraform-infrastructure-live

Sample project inspired from https://blog.gruntwork.io/how-to-create-reusable-infrastructure-with-terraform-modules-25526d65f73d https://github.com/gruntwork-io/terragrunt-infrastructure-live-example https://medium.com/@kief/https-medium-com-kief-using-pipelines-to-manage-environments-with-infrastructure-as-code-b37285a1cbf5
Running on Google GCE. 

## Required prereq

### Google Account
First, register a new account at google with your own email
https://accounts.google.com/SignUpWithoutGmail

### GCE account
Follow [these instructions](https://github.com/kelseyhightower/craft-kubernetes-workshop/blob/master/labs/create-gce-account.md)
to create a new GCE account, this will require your credit card information
although you will not be billed anything.

## Running

### Once
Use `scripts/bootstrap.sh` to bootstrap your environment. It creates a new google project and ensure that you have everything enabled and installed. 

### Get your environment running and up to date!

When you have run the bootstrap do the following to get an environment. Check the `terragrunt plan-all` output before apply

```
 cd gce_account
 terragrunt plan-all
 terragrunt apply-all
```
