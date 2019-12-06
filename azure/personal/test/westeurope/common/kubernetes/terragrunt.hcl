# include is a block, so make sure NOT to include an equals sign
include {
  path = find_in_parent_folders()
}

dependency "resourcegroup" {
  config_path = "../resourcegroup"
}

terraform {
  source = "git@github.com:sennerholm/terraform-infrastructure-modules.git//azure/kubernetes?ref=master"
}

# Overrides
#inputs = {
#

inputs = {
  k8s_resourcegroup_name = dependency.resourcegroup.outputs.name
  agent_count            = 2 # Set to same as min so we doesn't have to wait for scaleup when testing
}
