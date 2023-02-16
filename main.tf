# Define kubernetes cluster using kube module
module "kube_cluster" {
  source = "./kube"
}

output "kube_outputs" {
  value = module.kube_cluster
}