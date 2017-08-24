terragrunt {
  # Include all settings from the root terraform.tfvars file
  include = {
    path = "${find_in_parent_folders()}"
  }
  terraform = {
    source = "git@github.com:sennerholm/terraform-infrastructure-modules.git//gocd-server?ref=d57dff3ca2365be839e1d0d3e16e0836ed5c3570"
    extra_arguments "conditional_vars" {
      commands = ["${get_terraform_commands_that_need_vars()}"]

      required_var_files = [
        "${get_tfvars_dir()}/terraform.tfvars",

      ]

      optional_var_files = [
        "${get_tfvars_dir()}/../../region.tfvars",
        "${get_tfvars_dir()}/../environment.tfvars"
      ]
    }
  }
  dependencies {
    paths = ["../gke"]
  }
}
