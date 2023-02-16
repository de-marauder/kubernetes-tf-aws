resource "aws_instance" "master" {
  count         = var.master_node_count
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.master_instance_type

  subnet_id = aws_subnet.kube_pub_subnet[1].id

  tags = {
    Name = "${var.kube_clusterName}_master_node"
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

  # connection {
  #   type     = "ssh"
  #   user     = "root"
  #   host     = self.public_ip
  # }

  # provisioner "remote-exec" {
  #   script = file("${path.module}/kube_master_setup.sh")
  # }
}

resource "local_file" "master_host" {
  content         = join("\n", [for ip in aws_instance.master.*.public_ip : "${ip}"])
  filename        = "ansible/hosts/${var.kube_clusterName}-master-host"
  file_permission = 0600
}
resource "local_file" "master_private_ip" {
  content         = join("\n", [for ip in aws_instance.master.*.private_ip : "${ip}"])
  filename        = "ansible/hosts/${var.kube_clusterName}-master-private-ip"
  file_permission = 0600
}
