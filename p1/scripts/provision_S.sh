#!/bin/bash

# Installation de k3s sur la machine virtuelle "kthierryS" en mode contrôleur
curl -sfL https://get.k3s.io | K3S_KUBECONFIG_MODE="644" INSTALL_K3S_EXEC="--flannel-iface eth1" sh -
sleep 10

# Récupération du jeton du nœud
NODE_TOKEN="/var/lib/rancher/k3s/server/node-token"
while [ ! -e ${NODE_TOKEN} ]; do
    sleep 2
done

# Affichage du jeton du nœud (optionnel)
sudo cat ${NODE_TOKEN}

# Copie du jeton du nœud dans le répertoire partagé avec le nœud esclave (ServerWorker)
sudo cp ${NODE_TOKEN} /vagrant/



