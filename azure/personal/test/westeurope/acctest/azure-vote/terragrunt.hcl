# include is a block, so make sure NOT to include an equals sign
include {
  path = find_in_parent_folders()
}


terraform {
  source = "git@github.com:sennerholm/terraform-infrastructure-modules.git//azure/vote-terraform?ref=master"
}


dependency "kubernetes" {
  config_path = "../../common/kubernetes"
}
dependency "resourcegroup" {
  config_path = "../resourcegroup"
}


# Overrides
#inputs = {
#

inputs = {
  kubernetes_host                   = dependency.kubernetes.outputs.host
  kubernetes_client_key             = dependency.kubernetes.outputs.client_key
  kubernetes_client_certificate     = dependency.kubernetes.outputs.client_certificate
  kubernetes_cluster_ca_certificate = dependency.kubernetes.outputs.cluster_ca_certificate
  full_resourcegroup_name           = dependency.resourcegroup.outputs.name
  pod_scale                         = 200
}
