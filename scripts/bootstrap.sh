#!/bin/bash
set -e
project_number=3
project_name="$USER-terraform-project${project_number}"
tf_creds=~/.config/gcloud/terraform-project${project_number}.json
gcloud_cmd="gcloud --project $project_name"
gcloud --version >/dev/null 2>&1 || (echo "gcloud is required, please install, https://cloud.google.com/sdk/downloads " ; exit 1)

# Check if Terraform is installed
terraform --version >/dev/null 2>&1 || (echo "terraform is required, please install, https://www.terraform.io/intro/getting-started/install.html" ; exit 1)
# Check if Terraform is installed

terragrunt --version >/dev/null 2>&1 || (echo "terragrunt is required, please install, https://github.com/gruntwork-io/terragrunt/releases" ; exit 1)


echo "Install gcloud components"
for i in kubectl alpha beta gsutil
do
	gcloud -q components install $i
done 

if ! gcloud projects list | grep $project_name >> /dev/null 
then
	echo "Creating project"
	gcloud projects create $project_name 
	gcloud --project mikan-terraform-project config set compute/zone europe-west1-b
fi

echo Enable billing
gcloud alpha billing accounts projects link ${project_name} \
  --billing-account `gcloud -q beta billing accounts list | grep True | head -1 | awk '{print $1}'`


echo "Enable Required Google APIs"
for i in cloudresourcemanager.googleapis.com \
	cloudbilling.googleapis.com \
	iam.googleapis.com \
	compute.googleapis.com \
	container.googleapis.com
do
	$gcloud_cmd service-management enable $i
done

gcloud beta organizations list 2>&1 | grep 'Listed 0 items'  >/dev/null  || (echo "You are in an organizations, the permission stuff maybe different!"; read)


if ! $gcloud_cmd iam service-accounts list  | grep terraform@${project_name}.iam.gserviceaccount.com >> /dev/null 
then
echo "Creating service account"
$gcloud_cmd iam service-accounts create terraform \
  --display-name "Terraform admin account"
$gcloud_cmd iam service-accounts keys create ${tf_creds} \
  --iam-account terraform@${project_name}.iam.gserviceaccount.com
$gcloud_cmd projects add-iam-policy-binding ${project_name} \
  --member serviceAccount:terraform@${project_name}.iam.gserviceaccount.com \
  --role roles/editor
$gcloud_cmd projects add-iam-policy-binding ${project_name} \
  --member serviceAccount:terraform@${project_name}.iam.gserviceaccount.com \
  --role roles/storage.admin
fi


# Creating account config for project
cat > gce_account/terraform.tfvars <<EOF
// Created by scripts/bootstrap.sh
terragrunt = {
  remote_state {
    backend = "gcs"
    config {
      bucket = "${project_name}"
      project = "${project_name}"
      path   = "\${path_relative_to_include()}/terraform.tfstate"
      credentials = "${tf_creds}"
    }
  }
  terraform = {
    extra_arguments "account_vars" {
      commands = ["\${get_terraform_commands_that_need_vars()}"]

      required_var_files = [
        "\${get_parent_tfvars_dir()}/terraform.tfvars"

      ]
    }
  }
}
google_project = "${project_name}"
google_keyfile = "${tf_creds}"
EOF
