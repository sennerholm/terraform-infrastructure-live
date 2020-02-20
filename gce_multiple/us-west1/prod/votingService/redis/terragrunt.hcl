# include is a block, so make sure NOT to include an equals sign
include {
  path = find_in_parent_folders()
}


terraform {
  source = "git@github.com:sennerholm/terraform-infrastructure-modules.git//gce/redis?ref=85da54c79d3a48ac8db2ac81019f4116d4caa339"
}


inputs = {
}
