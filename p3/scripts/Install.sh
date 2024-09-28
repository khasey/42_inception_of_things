#!/bin/bash

VAGRANT_USER=vagrant

# Installation de Docker
echo -e "\e[32m[$(hostname)] Installing Docker\e[0m"
sudo apk add --update docker openrc
sudo rc-update add docker boot
sudo service docker start
echo -e "\e[32m[$(hostname)] Docker installed successfully\e[0m"

# Effacer le cluster K3D s'il existe déjà
if k3d cluster list | grep -q "dev-cluster"; then
    echo -e "\e[33m[$(hostname)] Cluster dev-cluster exists, deleting...\e[0m"
    sudo k3d cluster delete dev-cluster
fi

# Installation de K3D
echo -e "\e[32m[$(hostname)] Installing K3D on controller\e[0m"
curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | sudo bash
sudo k3d cluster create dev-cluster --port 8080:80@loadbalancer --port 8888:8888@loadbalancer
echo -e "\e[32m[$(hostname)] K3D installed successfully\e[0m"

# Configuration du fichier kubeconfig
sudo mkdir -p /home/$VAGRANT_USER/.kube
sudo cp /root/.kube/config /home/$VAGRANT_USER/.kube/config
sudo chown $VAGRANT_USER /home/$VAGRANT_USER/.kube/config

# Installation de kubectl
echo -e "\e[32m[$(hostname)] Installing Kubectl on controller\e[0m"
curl -LO https://storage.googleapis.com/kubernetes-release/release/v1.25.0/bin/linux/amd64/kubectl
chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin/kubectl
echo -e "\e[32m[$(hostname)] Kubectl installed successfully\e[0m"

# Attendre un peu pour s'assurer que tout est démarré
sleep 10

# Installation de ArgoCD
echo -e "\e[32m[$(hostname)] Installing ArgoCD\e[0m"
sudo kubectl create namespace argocd
sudo kubectl create namespace dev
sudo kubectl apply -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml -n argocd
sudo kubectl -n argocd set env deployment/argocd-server ARGOCD_SERVER_INSECURE=true

# Attendre que ArgoCD soit prêt
sleep 60

echo -e "\e[32m[$(hostname)] Waiting for the application to be deployed\e[0m"

# Forcer la synchronisation de l'application dans ArgoCD
sudo kubectl apply -f /sync/confs/application.yaml -n argocd
sudo kubectl -n argocd argocd app sync wil-app

# Boucle pour attendre que le déploiement soit disponible
MAX_RETRIES=10
RETRY_COUNT=0
while [[ $RETRY_COUNT -lt $MAX_RETRIES ]]; do
    sudo kubectl get deployment wil-playground -n dev
    if [[ $? -eq 0 ]]; then
        echo -e "\e[32m[$(hostname)] Deployment wil-playground found.\e[0m"
        sudo kubectl get deployment wil-playground -n dev -o yaml > /home/vagrant/deployment.yaml
        break
    fi
    echo -e "\e[33m[$(hostname)] Deployment not found, retrying...\e[0m"
    RETRY_COUNT=$((RETRY_COUNT + 1))
    sleep 10
done

if [[ $RETRY_COUNT -eq $MAX_RETRIES ]]; then
    echo -e "\e[31m[$(hostname)] Error: Deployment wil-playground not found after waiting.\e[0m"
    exit 1
fi

# Déploiement de l'ingress pour ArgoCD
echo -e "\e[32m[$(hostname)] Deploying Ingress for ArgoCD\e[0m"
sudo kubectl apply -f /sync/confs/ingress.yaml -n argocd

# Déploiement de l'application avec ArgoCD
echo -e "\e[32m[$(hostname)] Deploying wil-app\e[0m"
sudo kubectl apply -f /sync/confs/application.yaml -n argocd

# Attendre que les pods soient en cours d'exécution
sleep 60

# Vérifier que les pods sont bien créés
sudo kubectl get ns
sudo kubectl get pods -n dev

# Afficher le mot de passe ArgoCD
echo -e "\e[32mArgoCD initial admin password:\e[0m"
sudo kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d

echo -e "\e[32m[$(hostname)] Configured successfully\e[0m"
