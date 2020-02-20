# include is a block, so make sure NOT to include an equals sign
include {
  path = find_in_parent_folders()
}


terraform {
  source = "git@github.com:sennerholm/terraform-infrastructure-modules.git//gce/vote-terraform?ref=f3aec179721942edd78ec4e872ff4cc166232e38"
}


dependency "kubernetes" {
  config_path = "../../common/kubernetes"
}

dependency "redis" {
  config_path = "../redis"
}

inputs = {
  kubernetes_host                   = dependency.kubernetes.outputs.endpoint
  kubernetes_client_key             = dependency.kubernetes.outputs.client_key
  kubernetes_client_certificate     = dependency.kubernetes.outputs.client_certificate
  kubernetes_cluster_ca_certificate = dependency.kubernetes.outputs.cluster_ca_certificate
  redis_host                        = dependency.redis.outputs.host
  vote_title                        = "IaC tools"
  vote_alt1                         = "Terraform"
  vote_alt2                         = "Helm"
  pod_scale                         = 2
}
