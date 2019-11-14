#!/bin/bash
set -e
terraform destroy
az ad sp delete --id "http://terragrunt"
