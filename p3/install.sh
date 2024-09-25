#!/bin/bash

GREEN="\033[32m"
RED="\033[31m"
RESET="\033[0m"

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
    lsb-release

echo -e "${GREEN}[INFO]  Installation de Docker ===================>>>>>>>>//////${RESET}"

# Installation de Docker
apk add --no-cache docker
rc-update add docker boot
service docker start
addgroup vagrant docker

echo -e "${GREEN}[INFO]  Installation de K3d ===================>>>>>>>>//////${RESET}"

# Installation de K3d
curl -s https://raw.githubusercontent.com/rancher/k3d/main/install.sh | bash

echo -e "${GREEN}[INFO]  Installation de kubectl ===================>>>>>>>>//////${RESET}"

# Installation de kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
mv kubectl /usr/local/bin/

echo -e "${GREEN}[INFO]  Création du cluster K3d ===================>>>>>>>>//////${RESET}"

# Création du cluster K3d
k3d cluster create mycluster --api-port 6550 --port 8080:80@loadbalancer

echo -e "${GREEN}[INFO]  Installation de Argo CD ===================>>>>>>>>//////${RESET}"

# Installation de Argo CD
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

echo -e "${GREEN}[INFO]  Attente de la disponibilité de Argo CD ===================>>>>>>>>//////${RESET}"

# Attente de la disponibilité de Argo CD
kubectl rollout status -n argocd deployment/argocd-server

echo -e "${GREEN}[INFO]  Création du namespace 'dev' ===================>>>>>>>>//////${RESET}"

# Création du namespace 'dev'
kubectl create namespace dev

echo -e "${GREEN}[INFO]  Déploiement de l'application de Wil ===================>>>>>>>>//////${RESET}"

# Déploiement de l'application de Wil
cat <<EOF | kubectl apply -n dev -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: wil-playground
spec:
  replicas: 1
  selector:
    matchLabels:
      app: wil-playground
  template:
    metadata:
      labels:
        app: wil-playground
    spec:
      containers:
      - name: wil-playground
        image: wil42/playground:v1
        ports:
        - containerPort: 8888
EOF

# Création du service pour l'application
cat <<EOF | kubectl apply -n dev -f -
apiVersion: v1
kind: Service
metadata:
  name: wil-playground
spec:
  selector:
    app: wil-playground
  ports:
    - protocol: TCP
      port: 80
      targetPort: 8888
EOF

echo -e "${GREEN}[INFO]  Vérification du déploiement de l'application ===================>>>>>>>>//////${RESET}"

# Attendre que le pod soit prêt
kubectl rollout status -n dev deployment/wil-playground

echo -e "${GREEN}[INFO]  Script terminé avec succès ===================>>>>>>>>//////${RESET}"
