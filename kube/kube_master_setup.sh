#!/bin/bash
set -o errexit
sudo su
# =========================================================================
# First, set the following environment variables. Replace 10.0.0.10 with the IP of your master node.

# Set the private IP of the node as IPADDR
IPADDR="$(ip --json a s | jq -r '.[] | if .ifname == "eth0" then .addr_info[] | if .family == "inet" then .local else empty end else empty end')"
NODENAME=$(hostname -s)
POD_CIDR="192.168.0.0/16"
# =========================================================================

# =========================================================================
# Now, initialize the master node control plane configurations using the following kubeadm command.
# If your machine specs are above 2GB memory and 1vCPU, you can remove "Mem" and "NumCPU" from --ignore-preflight-errors

kubeadm init --apiserver-advertise-address=$IPADDR  --apiserver-cert-extra-sans=$IPADDR  --pod-network-cidr=$POD_CIDR --node-name $NODENAME --ignore-preflight-errors Swap,Mem,NumCPU
# kubeadm token create --print-join-command
# =========================================================================
# =========================================================================

export KUBECONFIG=/etc/kubernetes/admin.conf
echo "export KUBECONFIG=/etc/kubernetes/admin.conf" >>~/.bashrc

# deploy a pod network to the cluster
# kubectl apply -f [podnetwork].yaml

# Label worker nodes
# kubectl label node $NODE_HOSTNAME  node-role.kubernetes.io/worker=worker

# Install Metrics server
# kubectl apply -f https://raw.githubusercontent.com/techiescamp/kubeadm-scripts/main/manifests/metrics-server.yaml

# Access node metrics
# kubectl top nodes

# You can also view the pod CPU and memory metrics using the following command.
# kubectl top pod -n kube-system


###################################
# Deploy A Sample Nginx Application
###################################

######################################################################
# Create an Nginx deployment. Execute the following directly on the command line. It deploys the pod in the default namespace.

# cat <<EOF | kubectl apply -f -
# apiVersion: apps/v1
# kind: Deployment
# metadata:
#   name: nginx-deployment
# spec:
#   selector:
#     matchLabels:
#       app: nginx
#   replicas: 2 
#   template:
#     metadata:
#       labels:
#         app: nginx
#     spec:
#       containers:
#       - name: nginx
#         image: nginx:latest
#         ports:
#         - containerPort: 80      
# EOF
######################################################################


######################################################################
# Expose the Nginx deployment on a NodePort 32000

# cat <<EOF | kubectl apply -f -
# apiVersion: v1
# kind: Service
# metadata:
#   name: nginx-service
# spec:
#   selector: 
#     app: nginx
#   type: NodePort  
#   ports:
#     - port: 80
#       targetPort: 80
#       nodePort: 32000
# EOF
######################################################################
