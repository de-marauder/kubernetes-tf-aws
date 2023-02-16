#!/bin/bash
set -o errexit

# sudo su
apt update
# apt upgrade -y

# ===============================================================
# STEPS
# ===============================================================
# Install container runtime on all nodes- We will be using cri-o.
# Install Kubeadm, Kubelet, and kubectl on all the nodes.
# Initiate Kubeadm control plane configuration on the master node.
# Save the node join command with the token.
# Install the Calico network plugin.
# Join the worker node to the master node (control plane) using the join command.
# Validate all cluster components and nodes.
# Install Kubernetes Metrics Server
# Deploy a sample app and validate the app

# =========================================================================
# Execute the following commands on all the nodes for IPtables to see bridged traffic.

cat <<EOF | tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

modprobe overlay 
modprobe br_netfilter

# sysctl params required by setup, params persist across reboots
cat <<EOF | tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

# Apply sysctl params without reboot
sysctl --system
# =========================================================================

# =========================================================================
# For kubeadm to work properly, you need to disable swap on all the nodes using the following command.

swapoff -a
(
  crontab -l 2>/dev/null
  echo "@reboot /sbin/swapoff -a"
) | crontab - || true
# =========================================================================

# =========================================================================
# The basic requirement for a Kubernetes cluster is a container runtime. You can have any one of the following container runtimes.

# CRI-O
# containerd
# Docker Engine (using cri-dockerd)
# We will be using CRI-O instead of Docker for this setup as Kubernetes deprecated Docker engine

# Create the .conf file to load the modules at bootup

cat <<EOF | tee /etc/modules-load.d/crio.conf
overlay
br_netfilter
EOF

# Set up required sysctl params, these persist across reboots.
cat <<EOF | tee /etc/sysctl.d/99-kubernetes-cri.conf
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF
# =========================================================================

# =========================================================================
# Execute the following commands to enable overlayFS & VxLan pod communication.
modprobe overlay 
modprobe br_netfilter
# =========================================================================

# =========================================================================
# Set up required sysctl params, these persist across reboots.

cat <<EOF | tee /etc/sysctl.d/99-kubernetes-cri.conf
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF
# =========================================================================

# =========================================================================
# Reload the parameters.
sysctl --system
# =========================================================================

# =========================================================================
# Enable cri-o repositories for version 1.23

OS="xUbuntu_20.04"

VERSION="1.23"

cat <<EOF | tee /etc/apt/sources.list.d/devel:kubic:libcontainers:stable.list
deb https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/$OS/ /
EOF
cat <<EOF | tee /etc/apt/sources.list.d/devel:kubic:libcontainers:stable:cri-o:$VERSION.list
deb http://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable:/cri-o:/$VERSION/$OS/ /
EOF
# =========================================================================

# =========================================================================
# Add the gpg keys.

curl -L https://download.opensuse.org/repositories/devel:kubic:libcontainers:stable:cri-o:$VERSION/$OS/Release.key | apt-key --keyring /etc/apt/trusted.gpg.d/libcontainers.gpg add -
curl -L https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/$OS/Release.key | apt-key --keyring /etc/apt/trusted.gpg.d/libcontainers.gpg add -
# =========================================================================

# =========================================================================
# Update and install crio and crio-tools.

apt-get update
apt-get install cri-o cri-o-runc cri-tools -y
# =========================================================================

# =========================================================================
# Reload the systemd configurations and enable cri-o.

systemctl daemon-reload
systemctl enable crio --now
# =========================================================================

# =========================================================================
# Install the required dependencies.

apt-get update
apt-get install -y apt-transport-https ca-certificates curl
curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
# =========================================================================

# =========================================================================
# Add the GPG key and apt repository.

echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | tee /etc/apt/sources.list.d/kubernetes.list
# =========================================================================

# =========================================================================
# Update apt and install the latest version of kubelet, kubeadm, and kubectl.

apt-get update -y
apt-get install -y kubelet kubeadm kubectl
# =========================================================================

# =========================================================================
# You can use the following commands to find the latest versions.

apt update
apt-cache madison kubeadm | tac
# =========================================================================

# =========================================================================
# Specify the version as shown below.

apt-get install -y kubelet=1.26.1-00 kubectl=1.26.1-00 kubeadm=1.26.1-00
# =========================================================================

# =========================================================================
# Add hold to the packages to prevent upgrades.

apt-mark hold kubelet kubeadm kubectl
# =========================================================================

# =========================================================================
# Now we have all the required utilities and tools for configuring Kubernetes components using kubeadm.

# Add the node IP to KUBELET_EXTRA_ARGS.

apt-get install -y jq
local_ip="$(ip --json a s | jq -r '.[] | if .ifname == "eth1" then .addr_info[] | if .family == "inet" then .local else empty end else empty end')"
cat > /etc/default/kubelet << EOF
KUBELET_EXTRA_ARGS=--node-ip=$local_ip
EOF
# =========================================================================
