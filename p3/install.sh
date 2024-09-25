#!/bin/bash

set -e

GREEN='\033[0;32m'
RED='\033[0;31m'
RESET='\033[0m'

# Récupération du nom d'utilisateur depuis les arguments
USER_NAME="$1"
USER_HOME="/home/$USER_NAME"

echo -e "${GREEN}[INFO]  Mise à jour et installation des dépendances ===================>>>>>>>>//////${RESET}"

# Mise à jour de la liste des paquets et installation des dépendances
apk update
apk add --no-cache \
    curl \
    bash \
    sudo \
    openrc \
    iptables \
    ip6tables \
    ca-certificates \
    gnupg \
    lsb-release \
    shadow # Pour usermod

echo -e "${GREEN}[INFO]  Installation de Docker ===================>>>>>>>>//////${RESET}"

# Installation de Docker
apk add --no-cache docker
rc-update add docker boot
service docker start

# Ajout de l'utilisateur au groupe docker
usermod -aG docker $USER_NAME

echo -e "${GREEN}[INFO]  Installation de K3d ===================>>>>>>>>//////${RESET}"

# Installation de K3d
curl -s https://raw.githubusercontent.com/rancher/k3d/main/install.sh | bash

echo -e "${GREEN}[INFO]  Installation de kubectl ===================>>>>>>>>//////${RESET}"

# Télécharger une version spécifique de kubectl
KUBECTL_VERSION="v1.28.2" # Remplacez par la version souhaitée

curl -LO "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl"
chmod +x kubectl
mv kubectl /usr/local/bin/

echo -e "${GREEN}[INFO]  Création du cluster K3d ===================>>>>>>>>//////${RESET}"

# Création du cluster K3d
k3d cluster create mycluster --api-port 6550 --port 8080:80@loadbalancer

echo -e "${GREEN}[INFO]  Configuration du kubeconfig pour l'utilisateur $USER_NAME ===================>>>>>>>>//////${RESET}"

# Copier le kubeconfig pour l'utilisateur
mkdir -p $USER_HOME/.kube
k3d kubeconfig get mycluster > $USER_HOME/.kube/config
chown -R $USER_NAME:$USER_NAME $USER_HOME/.kube

# Exporter la variable KUBECONFIG pour le reste du script
export KUBECONFIG=/root/.kube/config

echo -e "${GREEN}[INFO]  Installation de Argo CD ===================>>>>>>>>//////${RESET}"

# Création des namespaces
kubectl create namespace argocd
kubectl create namespace dev

# Installation de Argo CD dans le namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

echo -e "${GREEN}[INFO]  Attente de la disponibilité de Argo CD ===================>>>>>>>>//////${RESET}"

# Attente que le déploiement argocd-server soit prêt
kubectl rollout status -n argocd deployment/argocd-server

echo -e "${GREEN}[INFO]  Attente que les CRDs d'Argo CD soient disponibles ===================>>>>>>>>//////${RESET}"

# Attendre que les CRDs soient disponibles
until kubectl get crd applications.argoproj.io > /dev/null 2>&1; do
  echo "Waiting for Argo CD CRDs to be ready..."
  sleep 5
done

echo -e "${GREEN}[INFO]  Application des configurations Argo CD ===================>>>>>>>>//////${RESET}"

# Appliquer le projet Argo CD dans le namespace argocd
if kubectl apply -n argocd -f /tmp/project.yaml; then
  echo "Project applied successfully."
else
  echo -e "${RED}[ERROR] Échec de l'application du projet.${RESET}"
  exit 1
fi

# Appliquer l'application Argo CD dans le namespace argocd
if kubectl apply -n argocd -f /tmp/application.yaml; then
  echo "Application applied successfully."
else
  echo -e "${RED}[ERROR] Échec de l'application de l'application Argo CD.${RESET}"
  exit 1
fi

echo -e "${GREEN}[INFO]  Attente de la synchronisation de l'application 'argocd-iot-app' ===================>>>>>>>>//////${RESET}"

# Attendre que l'application soit synchronisée et saine
TIMEOUT=600
INTERVAL=10
ELAPSED=0
while true; do
  if kubectl get application argocd-iot-app -n argocd > /dev/null 2>&1; then
    SYNC_STATUS=$(kubectl get application argocd-iot-app -n argocd -o jsonpath='{.status.sync.status}')
    HEALTH_STATUS=$(kubectl get application argocd-iot-app -n argocd -o jsonpath='{.status.health.status}')
    if [[ "$SYNC_STATUS" == "Synced" && "$HEALTH_STATUS" == "Healthy" ]]; then
      echo "Application is synced and healthy."
      break
    else
      echo "Application status: Sync=$SYNC_STATUS, Health=$HEALTH_STATUS"
    fi
  else
    echo "Application 'argocd-iot-app' not found yet."
  fi
  if [ $ELAPSED -ge $TIMEOUT ]; then
    echo -e "${RED}[ERROR] Timeout waiting for application to be synced and healthy.${RESET}"
    exit 1
  fi
  echo "Waiting for application to be synced and healthy..."
  sleep $INTERVAL
  ELAPSED=$((ELAPSED + INTERVAL))
done

echo -e "${GREEN}[INFO]  Vérification du déploiement de l'application ===================>>>>>>>>//////${RESET}"

# Attendre que le déploiement 'wil-playground' soit prêt dans le namespace 'dev'
kubectl rollout status -n dev deployment/wil-playground --timeout=600s

echo -e "${GREEN}[INFO]  Script terminé avec succès ===================>>>>>>>>//////${RESET}"
