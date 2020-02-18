# include is a block, so make sure NOT to include an equals sign
include {
  path = find_in_parent_folders()
}

terraform {
  source = "github.com/sennerholm/terraform-infrastructure-modules.git//gce/kubernetes?ref=master"
}

# Overrides
inputs = {
  gke_nr_of_nodes            = 1
}