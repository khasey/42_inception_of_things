#!/bin/bash

GREEN="\033[32m"
RED="\033[31m"
RESET="\033[0m"

echo "${GREEN}[INFO]  Installing k3s on server node (ip: $1) ===================>>>>>>>>//////${RESET}"

export INSTALL_K3S_EXEC="--write-kubeconfig-mode=644 --tls-san $(hostname) --node-ip $1  --bind-address=$1 --advertise-address=$1 "

echo "${GREEN}[INFO]  ARGUMENT PASSED TO INSTALL_K3S_EXEC: $INSTALL_K3S_EXEC ===================>>>>>>>>//////${RESET}"

apk add curl

curl -sfL https://get.k3s.io |  sh -

echo "${GREEN}[INFO]  Doing some sleep to wait for k3s to be ready ===================>>>>>>>>//////${RESET}"

sleep 10

sudo cp /var/lib/rancher/k3s/server/node-token /vagrant/scripts/

echo "${GREEN}[INFO]  Successfully installed k3s on server node ===================>>>>>>>>//////${RESET}"

echo "alias k='kubectl'" >> /etc/profile.d/00-aliases.sh