# terraform-infrastructure-live

Sample project inspired from https://blog.gruntwork.io/how-to-create-reusable-infrastructure-with-terraform-modules-25526d65f73d https://github.com/gruntwork-io/terragrunt-infrastructure-live-example https://medium.com/@kief/https-medium-com-kief-using-pipelines-to-manage-environments-with-infrastructure-as-code-b37285a1cbf5
Running on Google GCE. 

Use `scripts/bootstrap.sh` to bootstrap your environment. It creates a new google project and ensure that you have everything enabled and installed.

When you have run the bootstrap do the following to get an environment. Check the `terragrunt plan-all` output before apply

```
 cd gce_account
 terragrunt plan-all
 terragrunt apply-all
```
