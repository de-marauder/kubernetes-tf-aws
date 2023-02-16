resource "aws_internet_gateway" "kube_igw" {
  vpc_id = aws_vpc.kube_vpc.id

  tags = {
    Name = "${var.kube_clusterName}-igw"
  }
}

resource "aws_route_table" "kube_rtb_igw" {
  vpc_id = aws_vpc.kube_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.kube_igw.id
  }

  tags = {
    Name = "${var.kube_clusterName}-rtb"
  }
}

resource "aws_route_table_association" "kube_rtb_pub_assoc" {
  for_each       = aws_subnet.kube_pub_subnet
  subnet_id      = each.value.id
  route_table_id = aws_route_table.kube_rtb_igw.id
}
