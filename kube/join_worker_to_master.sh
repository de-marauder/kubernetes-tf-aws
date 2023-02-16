#! /bin bash
set -o errexit

MASTER_PRIVATE_IP=
TOKEN=
HASH=

kubeadm join $MASTER_PRIVATE_IP:6443 \
  --token $TOKEN \
  --discovery-token-ca-cert-hash $HASH
