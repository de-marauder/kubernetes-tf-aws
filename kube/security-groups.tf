# Allow ingress for all ports
resource "aws_security_group" "kube_node_sg" {
  name        = "allow all tcp"
  description = "Allow all inbound traffic"
  vpc_id      = aws_vpc.kube_vpc.id

  ingress {
    description = "HTTPS from internet"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # ingress {
  #   description = "HTTP from internet"
  #   from_port   = 80
  #   to_port     = 80
  #   protocol    = "tcp"
  #   cidr_blocks = ["0.0.0.0/0"]
  # }
  # ingress {
  #   description = "SSH from internet"
  #   from_port   = 22
  #   to_port     = 22
  #   protocol    = "tcp"
  #   cidr_blocks = ["0.0.0.0/0"]
  # }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.kube_clusterName}-node-sg"
  }
}
