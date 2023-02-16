resource "aws_subnet" "kube_pub_subnet" {
  for_each = var.kube_subnet

  vpc_id                  = aws_vpc.kube_vpc.id
  cidr_block              = var.kube_subnet[each.key]["cidr"]
  availability_zone       = var.kube_subnet[each.key]["az"]
  map_public_ip_on_launch = true

  tags = {
    "Name" = "${var.kube_clusterName}-subnet-${each.key}"
  }
}
