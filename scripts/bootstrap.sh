#!/bin/bash
set -e
    if [ -z "$1" ] || [ -z "$2" ]; then
        echo "Usage: bootstrap.sh [prefix] [project number]";
	exit 1
    fi
project_prefix=$1
project_number=$2
project_name="$1-$USER-tf-pr${project_number}"
tf_creds=~/.config/gcloud/$1-tf-pr${project_number}.json
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
	echo "Creating project called: $project_name"
	gcloud projects create $project_name 
	gcloud --project mikan-terraform-project config set compute/zone europe-west1-b
fi

echo Enable billing
gcloud alpha billing projects link ${project_name} \
  --billing-account `gcloud -q beta billing accounts list | grep True | head -1 | awk '{print $1}'`


echo "Enable Required Google APIs"
# In future, change to only the stuff needed to enable more apis, and move the other ones to the parts requiring them
for i in cloudresourcemanager.googleapis.com \
	cloudbilling.googleapis.com \
	iam.googleapis.com \
	compute.googleapis.com \
	container.googleapis.com
do
	$gcloud_cmd services enable $i
done

gcloud beta organizations list 2>&1 | grep 'Listed 0 items'  >/dev/null  || (echo "You are in an organizations, the permission stuff maybe different!")


if ! $gcloud_cmd iam service-accounts list  | grep terraform@${project_name}.iam.gserviceaccount.com >> /dev/null 
then
echo "Creating service account"
$gcloud_cmd iam service-accounts create terraform \
  --display-name "Terraform admin account"
$gcloud_cmd iam service-accounts keys create ${tf_creds} \
  --iam-account terraform@${project_name}.iam.gserviceaccount.com
$gcloud_cmd projects add-iam-policy-binding ${project_name} \
  --member serviceAccount:terraform@${project_name}.iam.gserviceaccount.com \
  --role roles/owner
# $gcloud_cmd projects add-iam-policy-binding ${project_name} \
#  --member serviceAccount:terraform@${project_name}.iam.gserviceaccount.com \
#   --role roles/storage.admin
# Needed for adding serviceaccounts. Maybe easier to change to project/owner instead...
# $gcloud_cmd projects add-iam-policy-binding ${project_name} \
#  --member serviceAccount:terraform@${project_name}.iam.gserviceaccount.com \
#  --role roles/resourcemanager.projectIamAdmin 
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

# Adding file in gocd-agent 
mkdir -p gce_account/europe-west1/prod/gocd-agent/terragrunt_in_pod
in_container_tf_creds="/var/run/secrets/cloud.google.com/service-account.json"
cat > gce_account/europe-west1/prod/gocd-agent/terragrunt_in_pod/terraform.tfvars<<EOF
// Created by scripts/bootstrap.sh
terragrunt = {
  remote_state {
    backend = "gcs"
    config {
      bucket = "${project_name}"
      project = "${project_name}"
      path   = "\${path_relative_to_include()}/terraform.tfstate"
      credentials = "${in_container_tf_creds}"
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
google_keyfile = "${in_container_tf_creds}"
EOF


# Creating bucket if needed
if ! gsutil ls -p ${project_name} 2>&1 | grep "gs://${project_name}/" > /dev/null 
then
  echo "Creating bucket to store terraform remote state"
  gsutil mb -p ${project_name} -l europe-west1 gs://${project_name}
fi

# Create ssh-key to be added to repos the go server should have the possiblitiy to reach
if [ ! -f gce_account/europe-west1/prod/gocd-server/ssh/id_rsa ]
then
  echo "Creating ssh key to be added to private repos the go server should have the possiblitiy to reach"
  mkdir -p gce_account/europe-west1/prod/gocd-server/ssh
  ssh-keygen -f gce_account/europe-west1/prod/gocd-server/ssh/id_rsa -t rsa -N ''
fi
# Enable Appengine
${gcloud_cmd} app create --region europe-west
google_auth=`base64 -w 0 ${tf_creds} 2>/dev/null` ||  google_auth=`base64 ${tf_creds}`

# Print stuff for the Circle CI
echo Please add the followin to CircleCI: 
echo 'Settings->Context->Create Context->org-global'
echo "GOOGLE_PROJECT_ID = ${project_name}"
echo "GOOGLE_COMPUTE_ZONE = europe-west1-b"
echo "GOOGLE_AUTH = ${google_auth}"
