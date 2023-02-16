variable "kube_clusterName" {
  type    = string
  default = "kube-cluster"
}

variable "kube_vpc_cidr" {
  type    = string
  default = "10.16.0.0/16"
}

variable "kube_subnet" {
  type = map(any)
  default = {
    1 = { cidr = "10.16.1.0/24", az = "us-east-1a" },
    2 = { cidr = "10.16.2.0/24", az = "us-east-1b" },
    3 = { cidr = "10.16.3.0/24", az = "us-east-1c" },
  }
}

variable "master_instance_type" {
  type    = string
  default = "t2.micro"
}

variable "master_node_count" {
  type    = number
  default = 1
}

variable "worker_instance_type" {
  type    = string
  default = "t2.micro"
}

variable "worker_node_count" {
  type    = number
  default = 2
}
