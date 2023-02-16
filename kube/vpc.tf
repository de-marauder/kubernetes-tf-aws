resource "aws_vpc" "kube_vpc" {
  cidr_block = var.kube_vpc_cidr

  tags = {
    "Name" = "${var.kube_clusterName}_vpc"
  }
}