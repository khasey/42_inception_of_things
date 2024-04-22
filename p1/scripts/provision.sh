#!/bin/bash

# Token personnalisé pour l'inscription des nœuds agents
K3S_TOKEN="mon_token_personnalise"

# Installation de K3s sur le premier nœud (Server)
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--node-name kthierryS --write-kubeconfig-mode 644 --token $K3S_TOKEN" sh -

# Installation de K3s sur le deuxième nœud (ServerWorker)
curl -sfL https://get.k3s.io | K3S_URL=https://192.168.56.110:6443 K3S_TOKEN="$K3S_TOKEN" sh -

# Configuration de l'accès SSH sans mot de passe
cat /vagrant/id_rsa.pub >> /home/vagrant/.ssh/authorized_keys
