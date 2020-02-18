#!/bin/bash

# Script to first run plan on "class" of terragrunt instances
# Then verify with OPA (Open policy Agent)
# And apply
set -e
if [ -z "$1" ]; then
    echo "Usage: $0 <system/component>";
    exit 1
fi
component=$1
for i in `\ls -d ../*/*/${component}`
do
  oldpwd=${PWD}
  echo "Found instance $i"
  cd $i
  echo "Running plan"
  terragrunt plan -out tfplan.binary
  terragrunt show -json tfplan.binary > tfplan.json
  opa=(opa eval --format pretty --data ${OLDPWD}/${component}.rego  --input tfplan.json "data.terraform.analysis.authz")
  if [ opa != "true" ]; then
    echo OPA policy failed, blast over limit
    opa eval --format pretty --data ${OLDPWD}/${component}.rego  --input tfplan.json "data.terraform.analysis.score"
    exit 1
  fi
  echo "Opa OK"
  terragrunt apply tfplan.binary
  cd -
done
