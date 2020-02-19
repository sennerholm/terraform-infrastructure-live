# include is a block, so make sure NOT to include an equals sign
include {
  path = find_in_parent_folders()
}


terraform {
  source = "git@github.com:sennerholm/terraform-infrastructure-modules.git//gce/redis?ref=master"
}


inputs = {
}
