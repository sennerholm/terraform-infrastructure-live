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
mkdir -p ~/gopath/bin
terragrunt --version >/dev/null 2>&1 || (echo "terragrunt is required, installing in ~/gopath/bin" ; curl https://github.com/gruntwork-io/terragrunt/releases/download/v0.23.38/terragrunt_linux_amd64 -o ~/gopath/bin/terragrunt; chmod a+x ~/gopath/bin/terragrunt)


echo "Install gcloud components"
for i in alpha beta gsutil
do
	gcloud -q components install $i
done 

if ! gcloud projects list | grep $project_name >> /dev/null 
then
	echo "Creating project called: $project_name"
	gcloud projects create $project_name 
	gcloud --project $project_name config set compute/zone europe-west1-b
fi

#echo Enable billing
gcloud alpha billing projects link ${project_name} \
  --billing-account `gcloud -q beta billing accounts list | grep True | head -1 | awk '{print $1}'`


echo "Enable Required Google APIs"
# In future, change to only the stuff needed to enable more apis, and move the other ones to the parts requiring them
for i in cloudresourcemanager.googleapis.com \
	cloudbilling.googleapis.com \
	iam.googleapis.com \
	compute.googleapis.com \
	container.googleapis.com \
	redis.googleapis.com
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
fi


# Creating account config for project
if [ ! -f ../../gce_edudevops/sourceme.sh ]; then
cat > ../../gce_edudevops/sourceme.sh <<EOF
#Created by scripts/gce_edudevops/bootstrap.sh
export GOOGLE_CREDENTIALS="${tf_creds}"
export GOOGLE_PROJECT="${project_name}"
#https://cloud.google.com/storage/docs/encryption#customer-supplied
# Didn't work as intended?
#export GOOGLE_ENCRYPTION_KEY=`hexdump -n 32 -e '8/4 "%08X" 1 "\n"' /dev/random | base64`
EOF
fi

source ../../gce_edudevops/sourceme.sh


# Creating bucket if needed
if ! gsutil ls -p ${project_name} 2>&1 | grep "gs://${project_name}/" > /dev/null 
then
  echo "Creating bucket to store terraform remote state"
  gsutil mb -p ${GOOGLE_PROJECT} -l europe-north1 gs://${GOOGLE_PROJECT}
fi

