resource "aws_instance" "worker" {
  count         = var.worker_node_count
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.worker_instance_type

  subnet_id = aws_subnet.kube_pub_subnet[2].id

  tags = {
    Name = "${var.kube_clusterName}_worker_node"
  }

  key_name = aws_key_pair.kube-keypair.key_name

  user_data = file("${path.module}/install_kube.sh")

  security_groups = [
    aws_security_group.kube_node_sg.id
  ]

  lifecycle {
    ignore_changes = [
      security_groups
    ]
  }

}

# resource "aws_instance" "worker" {
#   count         = var.worker_node_count
#   ami           = data.aws_ami.ubuntu.id
#   instance_type = var.worker_instance_type

#   subnet_id = aws_subnet.kube_pub_subnet[2]

#   tags = {
#     Name = "${var.kube_clusterName}_worker_node"
#   }
# }

# resource "aws_instance" "worker" {
#   count         = var.worker_node_count
#   ami           = data.aws_ami.ubuntu.id
#   instance_type = var.worker_instance_type

#   subnet_id = aws_subnet.kube_pub_subnet[3]

#   tags = {
#     Name = "${var.kube_clusterName}_worker_node"
#   }
# }

resource "local_file" "worker_host" {
  content         = join("\n", [for ip in aws_instance.worker.*.public_ip: "${ip}"])
  filename        = "ansible/hosts/${var.kube_clusterName}-worker-host"
  file_permission = 0600
}

resource "local_file" "worker_private_ip" {
  content         = join("\n", [for ip in aws_instance.worker.*.private_ip: "${ip}"])
  filename        = "ansible/hosts/${var.kube_clusterName}-worker-private-ip"
  file_permission = 0600
}
