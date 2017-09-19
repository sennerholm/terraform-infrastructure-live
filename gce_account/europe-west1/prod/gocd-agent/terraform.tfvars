terragrunt {
  # Include all settings from the root terraform.tfvars file
  include = {
    path = "${find_in_parent_folders()}"
  }
  terraform = {
    source = "git@github.com:sennerholm/terraform-infrastructure-modules.git//gocd-agent?ref=e7ae5246ffab08b96c2da0d82938d31967a73948"
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
    extra_arguments "terragrunt_config_path" {
      commands = ["${get_terraform_commands_that_need_vars()}"]
      arguments = [
        "-var", "ssh_key_path=${get_tfvars_dir()}/terragrunt_in_pod"
      ]
       
    }
  }
  dependencies {
    paths = ["../gke","../gocd-server"]
  }
}
terragrunt_config_path