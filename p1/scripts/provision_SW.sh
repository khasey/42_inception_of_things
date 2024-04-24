#!/bin/bash

# Script de provisionnement pour la machine virtuelle "kthierrySW"

# Installation de k3s sur la machine virtuelle "kthierrySW" en mode agent
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--flannel-iface eth1" K3S_URL=https://192.168.56.110:6443 K3S_TOKEN=$(sudo cat /vagrant/node-token) sh -
sleep 10

# Vérification de l'installation
kubectl version --client
