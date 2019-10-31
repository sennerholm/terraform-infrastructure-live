

# Inputs is an attribute, so an equals sign is REQUIRED
inputs = {
  subscription_name   = split("/", path_relative_to_include())[0]
  location            = split("/", path_relative_to_include())[1]
  resource_group_name = split("/", path_relative_to_include())[2]
}
