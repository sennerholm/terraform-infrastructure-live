
# Inputs is an attribute, so an equals sign is REQUIRED
inputs = {
  region            = split("/", path_relative_to_include())[0]
  env               = split("/", path_relative_to_include())[1]
  system            = split("/", path_relative_to_include())[2]
  component         = split("/", path_relative_to_include())[3]
  abs_path          = get_terragrunt_dir()
  project           = get_env("GOOGLE_PROJECT","project-not-set")
}

remote_state {
  backend = "gcs"
  config = {
    bucket = "${get_env("GOOGLE_PROJECT","project-not-set")}"
    project = "${get_env("GOOGLE_PROJECT","project-not-set")}"
    prefix   = "${path_relative_to_include()}/terraform.tfstate"
  }
}
